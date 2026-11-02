# Preservation of generic type information for Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep @com.google.gson.annotations.SerializedName class * { *; }

# flutter_local_notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.islamic.backtoprayer.back_to_prayer.PrayerAlertReceiver { *; }
-keep class com.islamic.backtoprayer.back_to_prayer.PrayerBootReceiver { *; }
-keep class com.islamic.backtoprayer.back_to_prayer.PrayerAlertService { *; }
-keep class androidx.work.** { *; }
-keep class android.support.v4.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**