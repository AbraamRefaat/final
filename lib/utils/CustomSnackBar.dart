// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/site_controller.dart';

class CustomSnackBar {
  SnackbarController snackBarSuccess(message) {
    return Get.snackbar(
      _getTitle("Success"),
      message.toString().capitalizeFirst.toString(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 5,
      duration: Duration(seconds: 3),
    );
  }

  SnackbarController snackBarSuccessBottom(message) {
    return Get.snackbar(
      _getTitle("Success"),
      message.toString().capitalizeFirst.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 5,
      duration: Duration(seconds: 3),
    );
  }

  SnackbarController snackBarError(message) {
    return Get.snackbar(
      _getTitle("Error"),
      message.toString().capitalizeFirst.toString(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 5,
      duration: Duration(seconds: 3),
    );
  }

  SnackbarController snackBarWarning(message) {
    return Get.snackbar(
      _getTitle("Warning"),
      message.toString().capitalizeFirst.toString(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xffF89406),
      colorText: Colors.white,
      borderRadius: 5,
      duration: Duration(seconds: 3),
    );
  }

  // Helper method to safely get title with fallback
  String _getTitle(String key) {
    try {
      // Try to get from SiteController
      if (Get.isRegistered<SiteController>()) {
        final siteController = Get.find<SiteController>();
        final title = siteController.lang[key];
        if (title != null && title.isNotEmpty) {
          return title;
        }
      }

      // Fallback to default English values
      switch (key) {
        case "Success":
          return "Success";
        case "Error":
          return "Error";
        case "Warning":
          return "Warning";
        default:
          return key;
      }
    } catch (e) {
      // If any error occurs, return the key as fallback
      return key;
    }
  }

  SnackbarController snackBarNotification(title, body) {
    return Get.snackbar(
      _getSafeTitle(title),
      _getSafeBody(body),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 5,
      duration: Duration(seconds: 10),
    );
  }

  // Helper method to safely get title with fallback
  String _getSafeTitle(dynamic title) {
    if (title == null ||
        title.toString().isEmpty ||
        title.toString() == "null") {
      return "Notification";
    }
    return title.toString().capitalizeFirst.toString();
  }

  // Helper method to safely get body with fallback
  String _getSafeBody(dynamic body) {
    if (body == null || body.toString().isEmpty || body.toString() == "null") {
      return "No message provided";
    }
    return body.toString().capitalizeFirst.toString();
  }
}
