import 'package:flutter/services.dart';

/// Short haptic tap for counters (Adhkar, Tasbeeh, settings preview).
class DeviceFeedback {
  static const _channel = MethodChannel('alnoor/device');

  static Future<void> vibrate() async {
    // Native vibrator with FLAG_IGNORE_GLOBAL_SETTING (see MainActivity).
    try {
      await _channel.invokeMethod<void>('vibrate');
    } catch (_) {}
    // Flutter platform haptics as a second path on devices that mute the motor API.
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
