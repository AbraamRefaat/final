import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/download_controller.dart';
import 'package:loader_overlay/loader_overlay.dart';

showDownloadAlertDialog(BuildContext context, String title, String fileUrl,
    DownloadController downloadController) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("${stctrl.lang["No"]}"),
    onPressed: () {
      context.loaderOverlay.hide();
      Navigator.of(Get.overlayContext!).pop();
    },
  );
  Widget yesButton = TextButton(
    child: Text("${stctrl.lang["Download"]}"),
    onPressed: () async {
      context.loaderOverlay.hide();
      Navigator.of(Get.overlayContext!).pop();
      downloadController.downloadFile(
        fileUrl,
        title,
      );
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      "$title",
      style: Get.textTheme.titleMedium,
    ),
    content: Text("${stctrl.lang["Would you like to download this file?"]}"),
    actions: [
      cancelButton,
      yesButton,
    ],
  );

  // show the dialog
  return alert;
}
