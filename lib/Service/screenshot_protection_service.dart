import 'package:flutter/services.dart';

/// Service to manage screenshot and screen recording protection across platforms
class ScreenshotProtectionService {
  static const MethodChannel _channel = MethodChannel('com.example.untitled2/screenshot_protection');
  
  static bool _isProtectionEnabled = true;
  
  /// Check if screenshot protection is currently enabled
  static bool get isProtectionEnabled => _isProtectionEnabled;
  
  /// Enable screenshot and screen recording protection
  /// 
  /// On Android: Uses FLAG_SECURE to prevent screenshots and screen recordings
  /// On iOS: Uses blur overlay and screen capture detection
  static Future<bool> enableProtection() async {
    try {
      final result = await _channel.invokeMethod('enableScreenshotProtection');
      _isProtectionEnabled = true;
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to enable screenshot protection: ${e.message}');
      return false;
    }
  }
  
  /// Disable screenshot and screen recording protection
  /// 
  /// Warning: This will allow users to take screenshots and record the screen
  /// Only use this if absolutely necessary for your app functionality
  static Future<bool> disableProtection() async {
    try {
      final result = await _channel.invokeMethod('disableScreenshotProtection');
      _isProtectionEnabled = false;
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to disable screenshot protection: ${e.message}');
      return false;
    }
  }
  
  /// Initialize screenshot protection (called automatically when app starts)
  /// This ensures protection is enabled by default
  static Future<void> initialize() async {
    await enableProtection();
  }
}
