import 'package:untitled2/Service/screenshot_protection_service.dart';

/// Helper class to manage screenshot protection throughout the app
/// 
/// This class provides convenient methods to control screenshot protection
/// based on different app states and user contexts.
class ScreenshotProtectionHelper {
  
  /// Enable protection for sensitive screens (login, payment, course content, etc.)
  static Future<void> enableForSensitiveContent() async {
    await ScreenshotProtectionService.enableProtection();
    print('Screenshot protection enabled for sensitive content');
  }
  
  /// Enable protection for course video content specifically
  static Future<void> enableForVideoContent() async {
    await ScreenshotProtectionService.enableProtection();
    print('Screenshot protection enabled for video content');
  }
  
  /// Enable protection for quiz content
  static Future<void> enableForQuizContent() async {
    await ScreenshotProtectionService.enableProtection();
    print('Screenshot protection enabled for quiz content');
  }
  
  /// Enable protection for payment/checkout screens
  static Future<void> enableForPaymentScreens() async {
    await ScreenshotProtectionService.enableProtection();
    print('Screenshot protection enabled for payment screens');
  }
  
  /// Temporarily disable protection (use with caution)
  /// This should only be used for specific features that require screenshots
  /// like sharing course completion certificates or similar legitimate use cases
  static Future<void> temporaryDisable() async {
    await ScreenshotProtectionService.disableProtection();
    print('Screenshot protection temporarily disabled');
  }
  
  /// Re-enable protection after temporary disable
  static Future<void> reEnable() async {
    await ScreenshotProtectionService.enableProtection();
    print('Screenshot protection re-enabled');
  }
  
  /// Check current protection status
  static bool get isProtectionActive => ScreenshotProtectionService.isProtectionEnabled;
}

/// Widget mixin to automatically handle screenshot protection for sensitive screens
mixin ScreenshotProtectionMixin {
  
  /// Call this in initState() of sensitive screens
  void enableScreenshotProtection() {
    ScreenshotProtectionHelper.enableForSensitiveContent();
  }
  
  /// Call this in dispose() if you need to clean up (usually not needed)
  void cleanupScreenshotProtection() {
    // Usually keep protection enabled, but can be customized per screen
  }
}
