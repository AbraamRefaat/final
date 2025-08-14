import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IOSCompatibility {
  /// Check if the current platform is iOS
  static bool get isIOS => Platform.isIOS;

  /// Get iOS-specific safe area padding
  static EdgeInsets getIOSSafeAreaPadding(BuildContext context) {
    if (!isIOS) return EdgeInsets.zero;

    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
    );
  }

  /// Configure iOS-specific system UI overlay
  static void configureIOSSystemUI() {
    if (!isIOS) return;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  /// Get iOS-specific text style
  static TextStyle? getIOSTextStyle(TextStyle? baseStyle) {
    if (!isIOS || baseStyle == null) return baseStyle;

    return baseStyle.copyWith(
      fontFamily: 'SF Pro Display', // iOS system font
    );
  }

  /// Handle iOS-specific navigation behavior
  static void handleIOSNavigation() {
    if (!isIOS) return;

    // iOS-specific navigation configurations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Get iOS-specific loading indicator
  static Widget getIOSLoadingIndicator({Color? color}) {
    if (!isIOS) {
      return CircularProgressIndicator(color: color);
    }

    return CupertinoActivityIndicator(
      color: color ?? Get.theme.primaryColor,
    );
  }

  /// Handle iOS-specific error messages
  static String getIOSErrorMessage(String error) {
    if (!isIOS) return error;

    // iOS-specific error message formatting
    return error.replaceAll('Android', 'iOS');
  }

  /// Configure iOS-specific app behavior
  static void configureIOSAppBehavior() {
    if (!isIOS) return;

    // iOS-specific configurations
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  /// Get iOS-specific button style
  static ButtonStyle? getIOSButtonStyle(ButtonStyle? baseStyle) {
    if (!isIOS || baseStyle == null) return baseStyle;

    return baseStyle.copyWith(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  /// Handle iOS-specific file path
  static String getIOSFilePath(String path) {
    if (!isIOS) return path;

    // iOS-specific file path handling
    return path.replaceAll('\\', '/');
  }

  /// Configure iOS-specific video player settings
  static Map<String, dynamic> getIOSVideoPlayerSettings() {
    if (!isIOS) return {};

    return {
      'allowsAirPlay': true,
      'allowsPictureInPicture': true,
      'requiresLinearPlayback': false,
    };
  }

  /// Get iOS-specific snackbar configuration
  static SnackBar getIOSSnackBar({
    required String message,
    Duration? duration,
    Color? backgroundColor,
  }) {
    if (!isIOS) {
      return SnackBar(
        content: Text(message),
        duration: duration ?? Duration(seconds: 3),
        backgroundColor: backgroundColor,
      );
    }

    return SnackBar(
      content: Text(message),
      duration: duration ?? Duration(seconds: 3),
      backgroundColor:
          backgroundColor ?? Get.theme.snackBarTheme.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  /// Handle iOS-specific permission requests
  static Future<bool> requestIOSPermissions(List<String> permissions) async {
    if (!isIOS) return true;

    // iOS-specific permission handling
    // This would integrate with permission_handler plugin
    return true;
  }

  /// Get iOS-specific theme data
  static ThemeData getIOSThemeData(ThemeData baseTheme) {
    if (!isIOS) return baseTheme;

    return baseTheme.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: baseTheme.primaryColor,
        brightness: baseTheme.brightness,
      ),
    );
  }
}
