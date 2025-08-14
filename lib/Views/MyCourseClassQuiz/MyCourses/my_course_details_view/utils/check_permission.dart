import 'package:flutter/material.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissions(BuildContext context) async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  if (statuses[Permission.storage] != statuses[PermissionStatus.granted]) {
    try {
      statuses = await [
        Permission.storage,
      ].request();
    } on Exception {
      debugPrint("Error");
    }

    if (statuses[Permission.storage] == statuses[PermissionStatus.granted])
      print("write  permission ok");
    else
      permissionsDenied(context);
  } else {
    print("write permission ok");
  }
}

void permissionsDenied(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext _context) {
        return SimpleDialog(
          title: Text(TranslationHelper.tr("Permission denied")),
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: Text(
                TranslationHelper.tr(
                    "You must grant all permission to use this application"),
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          ],
        );
      });
}
