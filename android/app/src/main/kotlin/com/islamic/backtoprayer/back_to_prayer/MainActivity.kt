package com.islamic.backtoprayer.back_to_prayer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
import androidx.core.app.NotificationCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private var introPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "alnoor/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "ringerMode" -> result.success(currentRingerMode())
                    "playIntro" -> result.success(playIntro())
                    "stopIntro" -> {
                        stopIntro()
                        result.success(null)
                    }
                    "vibrate" -> {
                        vibrateShort()
                        result.success(null)
                    }
                    "showNotification" -> {
                        val title = call.argument<String>("title") ?: "Al Noor"
                        val body = call.argument<String>("body") ?: ""
                        val sound = call.argument<String>("sound")
                        val id = call.argument<Int>("id") ?: 9001
                        result.success(showNotification(id, title, body, sound))
                    }
                    "schedulePrayerAlerts" -> {
                        val raw = call.argument<List<*>>("alerts") ?: emptyList<Any>()
                        val alerts = raw.mapNotNull { item ->
                            val map = item as? Map<*, *> ?: return@mapNotNull null
                            Alert.fromMap(map.entries.associate { it.key.toString() to it.value })
                        }
                        PrayerAlarms.schedule(this, alerts)
                        result.success(true)
                    }
                    "previewPrayerAlert" -> {
                        val alert = Alert.fromMap(
                            mapOf(
                                "id" to (call.argument<Int>("id") ?: 9001),
                                "when" to 0L,
                                "title" to (call.argument<String>("title") ?: "Al Noor"),
                                "body" to (call.argument<String>("body") ?: ""),
                                "mode" to (call.argument<String>("mode") ?: "shortTone"),
                                "sound" to (call.argument<String>("sound") ?: "adhan"),
                                "stop" to (call.argument<String>("stop") ?: "Stop"),
                            ),
                        )
                        result.success(PrayerAlarms.present(this, alert))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun currentRingerMode(): String {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> "silent"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "normal"
        }
    }

    private fun playIntro(): Boolean {
        if (currentRingerMode() != "normal") return false
        stopIntro()
        return try {
            val player = MediaPlayer()
            val afd = resources.openRawResourceFd(R.raw.intro_chime)
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            player.setVolume(0.9f, 0.9f)
            player.setOnCompletionListener {
                if (introPlayer === it) introPlayer = null
                it.release()
            }
            player.setOnErrorListener { mp, _, _ ->
                if (introPlayer === mp) introPlayer = null
                mp.release()
                true
            }
            player.prepare()
            player.start()
            introPlayer = player
            true
        } catch (e: Exception) {
            // Last resort: MediaPlayer.create defaults
            try {
                val player = MediaPlayer.create(this, R.raw.intro_chime) ?: return false
                player.setVolume(0.9f, 0.9f)
                player.setOnCompletionListener {
                    if (introPlayer === it) introPlayer = null
                    it.release()
                }
                player.start()
                introPlayer = player
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun stopIntro() {
        val player = introPlayer ?: return
        introPlayer = null
        try {
            if (player.isPlaying) player.stop()
        } catch (_: Exception) {
        }
        try {
            player.release()
        } catch (_: Exception) {
        }
    }

    private fun vibrateShort() {
        // View haptic ignores system "touch vibration" toggle when flagged.
        try {
            val flags = HapticFeedbackConstants.FLAG_IGNORE_VIEW_SETTING or
                HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING
            window.decorView.performHapticFeedback(
                HapticFeedbackConstants.KEYBOARD_TAP,
                flags,
            )
            window.decorView.performHapticFeedback(
                HapticFeedbackConstants.CLOCK_TICK,
                flags,
            )
        } catch (_: Exception) {
        }

        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vibrator.hasVibrator()) return

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val attrs = VibrationAttributes.Builder()
                    .setUsage(VibrationAttributes.USAGE_TOUCH)
                    .build()
                vibrator.vibrate(
                    VibrationEffect.createOneShot(55, VibrationEffect.DEFAULT_AMPLITUDE),
                    attrs,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createOneShot(55, VibrationEffect.DEFAULT_AMPLITUDE),
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(55)
            }
        } catch (_: Exception) {
            try {
                @Suppress("DEPRECATION")
                vibrator.vibrate(55)
            } catch (_: Exception) {
            }
        }
    }

    private fun showNotification(id: Int, title: String, body: String, sound: String?): Boolean {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "alnoor_" + (sound ?: "plain") + "_v5"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Prayer times",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.enableVibration(sound != null)
            if (sound != null) {
                val rawId = resources.getIdentifier(sound, "raw", packageName)
                if (rawId != 0) {
                    val uri = Uri.parse("android.resource://$packageName/$rawId")
                    channel.setSound(
                        uri,
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build(),
                    )
                }
            }
            manager.createNotificationChannel(channel)
        }

        val open = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pending = PendingIntent.getActivity(this, id, open, flags)
        val logo = BitmapFactory.decodeResource(resources, R.mipmap.launcher_icon)
        val builder = NotificationCompat.Builder(this, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .setLargeIcon(logo)

        return try {
            builder.setSmallIcon(R.drawable.ic_stat_alnoor)
            manager.notify(id, builder.build())
            true
        } catch (first: Exception) {
            try {
                builder.setSmallIcon(android.R.drawable.ic_dialog_info)
                manager.notify(id, builder.build())
                true
            } catch (second: Exception) {
                false
            }
        }
    }

    override fun onDestroy() {
        stopIntro()
        super.onDestroy()
    }
}
