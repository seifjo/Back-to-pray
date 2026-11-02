package com.islamic.backtoprayer.back_to_prayer

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

/**
 * Schedules prayer alerts that still fire after the app is closed.
 * Short mode shows a notification. Adhan mode shows a notification and plays the raw audio.
 */
object PrayerAlarms {
    private const val PREFS = "alnoor_prayer_alarms"
    private const val KEY = "alerts"
    const val ACTION_FIRE = "com.islamic.backtoprayer.PRAYER_ALERT"
    const val ACTION_STOP = "com.islamic.backtoprayer.STOP_ADHAN"

    fun schedule(context: Context, alerts: List<Alert>) {
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (id in 1..5) {
            manager.cancel(fireIntent(context, id, null))
        }
        val stored = JSONArray()
        for (alert in alerts) {
            if (alert.whenMillis <= System.currentTimeMillis()) continue
            scheduleOne(context, manager, alert)
            stored.put(alert.toJson())
        }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY, stored.toString())
            .commit()
        if (context is android.app.Activity) {
            maybeAskBattery(context)
        }
    }

    private fun maybeAskBattery(activity: android.app.Activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val power = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        if (power.isIgnoringBatteryOptimizations(activity.packageName)) return
        val prefs = activity.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (prefs.getBoolean("asked_battery", false)) return
        prefs.edit().putBoolean("asked_battery", true).apply()
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${activity.packageName}")
        }
        try {
            activity.startActivity(intent)
        } catch (ignored: Exception) {
        }
    }

    fun restore(context: Context) {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY, null) ?: return
        val now = System.currentTimeMillis()
        val alerts = mutableListOf<Alert>()
        val array = JSONArray(raw)
        for (index in 0 until array.length()) {
            val alert = Alert.fromJson(array.getJSONObject(index))
            if (alert.whenMillis > now) alerts.add(alert)
        }
        schedule(context, alerts)
    }

    fun present(context: Context, alert: Alert): Boolean {
        val app = context.applicationContext
        val adhan = alert.mode == "adhan"
        return try {
            PrayerNotices.show(app, alert, ongoing = adhan)
            if (!adhan) return true
            val intent = serviceIntent(app, alert)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                app.startForegroundService(intent)
            } else {
                app.startService(intent)
            }
            true
        } catch (error: Exception) {
            try {
                PrayerNotices.show(app, alert, ongoing = false, rawSound = adhan)
                true
            } catch (second: Exception) {
                false
            }
        }
    }

    private fun scheduleOne(context: Context, manager: AlarmManager, alert: Alert) {
        val fire = fireIntent(context, alert.id, alert)
        val show = PendingIntent.getActivity(
            context,
            alert.id + 200,
            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java),
            pendingFlags(),
        )
        val exactAllowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms()
        if (exactAllowed) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    manager.setAlarmClock(AlarmManager.AlarmClockInfo(alert.whenMillis, show), fire)
                    return
                }
            } catch (ignored: Exception) {
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alert.whenMillis, fire)
                } else {
                    manager.setExact(AlarmManager.RTC_WAKEUP, alert.whenMillis, fire)
                }
                return
            } catch (ignored: Exception) {
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alert.whenMillis, fire)
        } else {
            manager.set(AlarmManager.RTC_WAKEUP, alert.whenMillis, fire)
        }
    }

    private fun fireIntent(context: Context, id: Int, alert: Alert?): PendingIntent {
        val intent = Intent(context, PrayerAlertReceiver::class.java).apply {
            action = ACTION_FIRE
            putExtra("id", id)
            if (alert != null) {
                putExtra("title", alert.title)
                putExtra("body", alert.body)
                putExtra("mode", alert.mode)
                putExtra("sound", alert.sound)
                putExtra("stop", alert.stop)
            }
        }
        return PendingIntent.getBroadcast(context, id, intent, pendingFlags())
    }

    private fun pendingFlags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    private fun serviceIntent(context: Context, alert: Alert): Intent {
        return Intent(context, PrayerAlertService::class.java).apply {
            putExtra("id", alert.id)
            putExtra("title", alert.title)
            putExtra("body", alert.body)
            putExtra("mode", alert.mode)
            putExtra("sound", alert.sound)
            putExtra("stop", alert.stop)
        }
    }

    fun alertFromIntent(intent: Intent?): Alert? {
        if (intent == null) return null
        val id = intent.getIntExtra("id", 0)
        if (id == 0) return null
        return Alert(
            id = id,
            whenMillis = 0L,
            title = intent.getStringExtra("title") ?: "Al Noor",
            body = intent.getStringExtra("body") ?: "",
            mode = intent.getStringExtra("mode") ?: "shortTone",
            sound = intent.getStringExtra("sound") ?: "adhan",
            stop = intent.getStringExtra("stop") ?: "Stop",
        )
    }
}

data class Alert(
    val id: Int,
    val whenMillis: Long,
    val title: String,
    val body: String,
    val mode: String,
    val sound: String,
    val stop: String = "Stop",
) {
    fun toJson(): JSONObject {
        return JSONObject()
            .put("id", id)
            .put("when", whenMillis)
            .put("title", title)
            .put("body", body)
            .put("mode", mode)
            .put("sound", sound)
            .put("stop", stop)
    }

    companion object {
        fun fromJson(json: JSONObject): Alert {
            return Alert(
                id = json.getInt("id"),
                whenMillis = json.getLong("when"),
                title = json.optString("title", "Al Noor"),
                body = json.optString("body", ""),
                mode = json.optString("mode", "shortTone"),
                sound = json.optString("sound", "adhan"),
                stop = json.optString("stop", "Stop"),
            )
        }

        fun fromMap(map: Map<String, Any?>): Alert {
            return Alert(
                id = (map["id"] as Number).toInt(),
                whenMillis = (map["when"] as? Number)?.toLong() ?: 0L,
                title = map["title"] as? String ?: "Al Noor",
                body = map["body"] as? String ?: "",
                mode = map["mode"] as? String ?: "shortTone",
                sound = map["sound"] as? String ?: "adhan",
                stop = map["stop"] as? String ?: "Stop",
            )
        }
    }
}

class PrayerAlertReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        val app = context.applicationContext
        val power = app.getSystemService(Context.POWER_SERVICE) as PowerManager
        val lock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "alnoor:alert")
        lock.setReferenceCounted(false)
        lock.acquire(20_000)
        try {
            deliver(app, intent)
        } finally {
            Handler(Looper.getMainLooper()).postDelayed({
                if (lock.isHeld) lock.release()
                pending.finish()
            }, 5000)
        }
    }

    private fun deliver(context: Context, intent: Intent) {
        if (intent.action == PrayerAlarms.ACTION_STOP) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val id = intent.getIntExtra("id", 0)
            if (id != 0) manager.cancel(id)
            context.stopService(Intent(context, PrayerAlertService::class.java))
            return
        }
        if (intent.hasExtra("title")) {
            val direct = PrayerAlarms.alertFromIntent(intent)
            if (direct != null) {
                PrayerAlarms.present(context, direct)
                return
            }
        }
        val id = intent.getIntExtra("id", 0)
        val raw = context.getSharedPreferences("alnoor_prayer_alarms", Context.MODE_PRIVATE)
            .getString("alerts", null) ?: return
        val array = JSONArray(raw)
        for (index in 0 until array.length()) {
            val alert = Alert.fromJson(array.getJSONObject(index))
            if (alert.id == id) {
                PrayerAlarms.present(context, alert)
                return
            }
        }
    }
}

class PrayerBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        PrayerAlarms.restore(context.applicationContext)
    }
}

object PrayerNotices {
    fun show(
        context: Context,
        alert: Alert,
        ongoing: Boolean,
        rawSound: Boolean = false,
    ): android.app.Notification {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = ensureChannel(context, manager, alert.mode, rawSound, alert.sound)
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        val pending = PendingIntent.getActivity(context, alert.id, open, flags())
        val builder = NotificationCompat.Builder(context, channelId)
            .setContentTitle(alert.title)
            .setContentText(alert.body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(alert.body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(!ongoing)
            .setOngoing(ongoing)
            .setContentIntent(pending)
        if (ongoing) {
            val stop = PendingIntent.getBroadcast(
                context,
                alert.id + 300,
                Intent(context, PrayerAlertReceiver::class.java).apply {
                    action = PrayerAlarms.ACTION_STOP
                    putExtra("id", alert.id)
                },
                flags(),
            )
            builder.addAction(0, alert.stop, stop)
        }
        try {
            val logo = BitmapFactory.decodeResource(context.resources, R.mipmap.launcher_icon)
            if (logo != null) builder.setLargeIcon(logo)
        } catch (ignored: Exception) {
        }
        val notification = try {
            builder.setSmallIcon(R.drawable.ic_stat_alnoor).build()
        } catch (first: Exception) {
            builder.setSmallIcon(android.R.drawable.ic_dialog_info).build()
        }
        manager.notify(alert.id, notification)
        return notification
    }

    private fun ensureChannel(
        context: Context,
        manager: NotificationManager,
        mode: String,
        rawSound: Boolean,
        soundName: String,
    ): String {
        val channelId = when {
            rawSound -> "alnoor_adhan_file_v7"
            mode == "adhan" -> "alnoor_adhan_v6"
            mode == "silent" -> "alnoor_silent_v6"
            else -> "alnoor_short_v6"
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return channelId
        val channel = NotificationChannel(channelId, "Prayer times", NotificationManager.IMPORTANCE_HIGH)
        channel.lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
        if (rawSound) {
            val rawId = context.resources.getIdentifier(soundName, "raw", context.packageName)
            if (rawId != 0) {
                val uri = Uri.parse("android.resource://${context.packageName}/$rawId")
                channel.setSound(
                    uri,
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
            }
            channel.enableVibration(true)
        } else if (mode == "shortTone") {
            channel.enableVibration(true)
        } else {
            channel.setSound(null, null)
            channel.enableVibration(mode == "adhan")
        }
        manager.createNotificationChannel(channel)
        return channelId
    }

    private fun flags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }
}

class PrayerAlertService : Service() {
    private val main = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var focusRequest: AudioFocusRequest? = null
    private var currentId: Int = 0
    private var finished = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == PrayerAlarms.ACTION_STOP) {
            releasePlayback()
            if (currentId != 0) {
                val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                manager.cancel(currentId)
            }
            stopServiceQuietly()
            return START_NOT_STICKY
        }
        val alert = PrayerAlarms.alertFromIntent(intent)
        if (alert == null || alert.mode != "adhan") {
            if (alert != null) PrayerNotices.show(this, alert, ongoing = false)
            stopServiceQuietly()
            return START_NOT_STICKY
        }
        currentId = alert.id
        finished = false
        val notification = PrayerNotices.show(this, alert, ongoing = true)
        try {
            promote(alert.id, notification)
        } catch (error: Exception) {
            PrayerNotices.show(this, alert, ongoing = false, rawSound = true)
            stopSelf()
            return START_NOT_STICKY
        }
        play(alert)
        return START_NOT_STICKY
    }

    private fun extendPlayback(id: Int, notification: android.app.Notification) {
        if (finished || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        try {
            startForeground(
                id,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } catch (ignored: Exception) {
        }
    }

    private fun promote(id: Int, notification: android.app.Notification) {
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                id,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE,
            )
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                id,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(id, notification)
        }
    }

    private fun play(alert: Alert) {
        releasePlayback()
        val rawId = resources.getIdentifier(alert.sound, "raw", packageName)
        if (rawId == 0) {
            finishKeepingNotice(alert)
            return
        }
        val audio = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val media = MediaPlayer()
        media.setAudioAttributes(audio)
        media.setWakeMode(this, PowerManager.PARTIAL_WAKE_LOCK)
        media.setDataSource(this, Uri.parse("android.resource://$packageName/$rawId"))
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(audio)
                .build()
            focusRequest = request
            audioManager.requestAudioFocus(request)
        }
        media.setOnCompletionListener { finishKeepingNotice(alert) }
        media.setOnErrorListener { _, _, _ ->
            finishKeepingNotice(alert)
            true
        }
        player = media
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        val lock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "alnoor:adhan")
        lock.setReferenceCounted(false)
        lock.acquire(8 * 60 * 1000L)
        wakeLock = lock
        Thread {
            try {
                media.prepare()
                if (finished) return@Thread
                media.start()
                val notice = PrayerNotices.show(this, alert, ongoing = true)
                main.post { extendPlayback(alert.id, notice) }
            } catch (error: Exception) {
                finishKeepingNotice(alert)
            }
        }.start()
    }

    private fun finishKeepingNotice(alert: Alert) {
        main.post {
            if (finished) return@post
            finished = true
            releasePlayback()
            PrayerNotices.show(this, alert, ongoing = false)
            stopServiceQuietly()
        }
    }

    private fun releasePlayback() {
        val media = player
        player = null
        if (media != null) {
            try {
                if (media.isPlaying) media.stop()
            } catch (ignored: Exception) {
            }
            media.release()
        }
        val lock = wakeLock
        wakeLock = null
        if (lock != null && lock.isHeld) lock.release()
        val request = focusRequest
        focusRequest = null
        if (request != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.abandonAudioFocusRequest(request)
        }
    }

    private fun stopServiceQuietly() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_DETACH)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(false)
        }
        stopSelf()
    }

    override fun onTimeout(startId: Int) {
        releasePlayback()
        stopServiceQuietly()
    }

    override fun onDestroy() {
        releasePlayback()
        super.onDestroy()
    }
}
