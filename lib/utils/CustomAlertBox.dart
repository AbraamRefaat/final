// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Controller/dashboard_controller.dart';

// import 'package:get_storage/get_storage.dart';

showLoginAlertDialog(title1, boday1, buttonName) {
  final DashboardController dashboardController =
      Get.put(DashboardController());
  // set up the button
  Widget okButton = TextButton(
    child: Text(buttonName),
    onPressed: () {
      Get.back();
      Get.back();
      // Navigator.of(Get.context!, rootNavigator: true).pop();
      Navigator.of(Get.context!, rootNavigator: true).pop();
      // Navigator.of(Get.context!, rootNavigator: true).pop();
      dashboardController.persistentTabController.jumpToTab(2);
      dashboardController.changeTabIndex(2);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title1,
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    content: Text(
      boday1,
      style: TextStyle(color: Colors.black, fontSize: 16),
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  Get.dialog(alert);
}
