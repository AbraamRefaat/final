import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/download_controller.dart';
import 'package:untitled2/Model/Course/FileElement.dart';
import 'package:untitled2/Views/Downloads/DownloadsFolder.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/widgets/download_alert_dialog.dart';
import 'package:untitled2/utils/open_files.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:untitled2/utils/file_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Widget fileDetailsWidget(BuildContext context, FileElement file,
    DownloadController downloadController) {
  return InkWell(
    onTap: () async {
      late PermissionStatus status;

      // Check the Android version
      final androidVersion = await _getAndroidVersion();

      // Request storage permission based on Android version
      if (Platform.isAndroid) {
        if (androidVersion >= 30) {
          // Android 11 and above
          if (await Permission.manageExternalStorage.isPermanentlyDenied) {
            openAppSettings();
          } else {
            status = await Permission.manageExternalStorage.request();
          }
        } else {
          // Android 10 and below
          if (await Permission.storage.isPermanentlyDenied) {
            openAppSettings();
          } else {
            status = await Permission.storage.request();
          }
        }
      } else {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        context.loaderOverlay.show();
        String filePath;

        final extension = p.extension(file.file ?? '');

        // Get the correct directory based on the platform
        Directory downloadsDirectory;
        if (Platform.isAndroid) {
          downloadsDirectory =
              await getExternalStorageDirectory() ?? Directory('');
        } else {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        // Create the Downloads directory if it does not exist
        String folderPath = p.join(downloadsDirectory.path, 'Downloads');
        Directory(folderPath).createSync(recursive: true);

        filePath = "$folderPath/${companyName}_${file.fileName}$extension";

        final isCheck = await FileUtils.checkDocument(filePath: filePath);

        debugPrint("Exist: $isCheck");

        if (isCheck) {
          context.loaderOverlay.hide();
          if (extension.contains('.zip')) {
            Get.to(() => DownloadsFolder(
                  filePath: folderPath,
                  title: TranslationHelper.tr("My Downloads"),
                ));
          } else {
            // Open the document
            openAppFile(filePath);
          }
        } else {
          // Initiate the download process
          final DownloadController downloadController =
              Get.put(DownloadController());
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return showDownloadAlertDialog(
                context,
                file.fileName ?? "",
                file.file ?? '',
                downloadController,
              );
            },
          );
        }
      } else {
        // Handle the case when permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationHelper.tr(
                'Storage permission is required to access files.')),
          ),
        );
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              file.fileName != null
                  ? Container(
                      child: Icon(
                        FontAwesomeIcons.fileDownload,
                        color: Get.theme.primaryColor,
                        size: 16,
                      ),
                    )
                  : Container(),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  file.fileName.toString(),
                  style: Get.textTheme.titleMedium,
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Divider(),
        ],
      ),
    ),
  );
}

Future<int> _getAndroidVersion() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    final androidInfo = await deviceInfo.androidInfo;
    // Get the Android version as an integer
    return androidInfo.version.sdkInt;
  } catch (e) {
    print('Failed to get Android version: $e');
    return 0;
  }
}
