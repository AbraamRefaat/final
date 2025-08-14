import 'package:flutter/material.dart';
import 'dart:io';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isWindows() {
    return Platform.isWindows;
  }

  static bool isMobilePlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static double getAdaptiveWidth(BuildContext context, double mobileWidth,
      {double? tabletWidth, double? desktopWidth}) {
    if (isDesktop(context)) {
      return desktopWidth ?? mobileWidth * 1.5;
    } else if (isTablet(context)) {
      return tabletWidth ?? mobileWidth * 1.2;
    }
    return mobileWidth;
  }

  static double getAdaptiveHeight(BuildContext context, double mobileHeight,
      {double? tabletHeight, double? desktopHeight}) {
    if (isDesktop(context)) {
      return desktopHeight ?? mobileHeight * 1.3;
    } else if (isTablet(context)) {
      return tabletHeight ?? mobileHeight * 1.1;
    }
    return mobileHeight;
  }

  static double getAdaptiveFontSize(BuildContext context, double mobileSize,
      {double? tabletSize, double? desktopSize}) {
    if (isDesktop(context)) {
      return desktopSize ?? mobileSize * 1.2;
    } else if (isTablet(context)) {
      return tabletSize ?? mobileSize * 1.1;
    }
    return mobileSize;
  }

  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double horizontal = 20.0,
    double vertical = 15.0,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(
        horizontal: desktopHorizontal ?? horizontal * 2,
        vertical: desktopVertical ?? vertical * 1.5,
      );
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: tabletHorizontal ?? horizontal * 1.5,
        vertical: tabletVertical ?? vertical * 1.2,
      );
    }
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static double getAdaptiveSpacing(BuildContext context, double mobileSpacing,
      {double? tabletSpacing, double? desktopSpacing}) {
    if (isDesktop(context)) {
      return desktopSpacing ?? mobileSpacing * 1.5;
    } else if (isTablet(context)) {
      return tabletSpacing ?? mobileSpacing * 1.2;
    }
    return mobileSpacing;
  }

  static int getAdaptiveItemCount(BuildContext context, int mobileCount,
      {int? tabletCount, int? desktopCount}) {
    if (isDesktop(context)) {
      return desktopCount ?? (mobileCount * 2).clamp(1, 10);
    } else if (isTablet(context)) {
      return tabletCount ?? (mobileCount * 1.5).round().clamp(1, 8);
    }
    return mobileCount;
  }

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.0; // Max width for desktop
    } else if (isTablet(context)) {
      return 800.0; // Max width for tablet
    }
    return MediaQuery.of(context).size.width; // Full width for mobile
  }

  static Widget responsiveWrapper({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
