import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:untitled2/utils/open_files.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/utils/widgets/progress_dialog_custom.dart';
import 'package:open_document/open_document.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Views/Downloads/DownloadsFolder.dart';

class DownloadController extends GetxController
    with GetTickerProviderStateMixin {
  var downloadUrl = "".obs;
  var isDownloading = false.obs;
  var downloadedPath = "".obs;
  var downloadingText = "${stctrl.lang["Downloading"]}".obs;
  var received = "".obs();
  Rx<double> downloadValue = 0.0.obs;
  CancelToken? token;
  Dio dio = Dio();
  var fileExists = false.obs;

  static String getExtension(String url) {
    return p.extension(url);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> downloadFile(String url, String title) async {
    late PermissionStatus status;

    // Check the Android version
    final androidVersion = await _getAndroidVersion();
    // Request storage permission

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
      String filePath;
      final extension = getExtension(url);

      // Get the downloads directory
      Directory downloadsDirectory = Platform.isAndroid
          ? await getExternalStorageDirectory() ?? Directory('')
          : await getApplicationDocumentsDirectory();

      // Create the Downloads directory if it does not exist
      String folderPath = p.join(downloadsDirectory.path, 'Downloads');
      Directory(folderPath).createSync(recursive: true);

      filePath = "$folderPath/${companyName}_$title$extension";

      try {
        // Check if the file already exists
        final isCheck = await OpenDocument.checkDocument(filePath: filePath);
        debugPrint("File exists: $isCheck");

        if (!isCheck) {
          await download(
            filePath: filePath,
            url: url,
          ).then((value) async {
            if (value != null) {
              filePath = value;

              if (extension.contains('.zip')) {
                Get.to(() => DownloadsFolder(filePath: folderPath));
              } else {
                print('Opening document...');
                openAppFile(filePath);
              }
            }
          });
        } else {
          print('File already exists.');
          openAppFile(filePath);
        }
      } catch (e) {
        debugPrint("Error: $e");
        CustomSnackBar()
            .snackBarError("${stctrl.lang["Error downloading file"]}");
      }
    } else {
      // Handle the case when permission is denied
      CustomSnackBar()
          .snackBarError("Storage permission is required to download files.");
    }
  }

  Future<String?> download({
    required String filePath,
    required String url,
  }) async {
    ProgressDialog pd = ProgressDialog(context: Get.context!);
    token = CancelToken();
    var downloadingUrls = Map<String, CancelToken>();
    downloadingUrls[url] = token!;
    isDownloading(true);
    pd.show(
      max: 100,
      msg: "${stctrl.lang["Downloading"]}",
      backgroundColor: Get.theme.cardColor,
      progressType: ProgressType.valuable,
      barrierColor: Colors.black.withOpacity(0.7),
      stopButton: () {
        token?.cancel();
        pd.close();
      },
    );

    try {
      print("Downloading from: $url to path: $filePath");
      var response = await dio.download(
        rootUrl + '/' + url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) async {
          int progress = (((receivedBytes / totalBytes) * 100).toInt());
          print("Progress: $progress%");
          pd.update(value: progress);
          if (progress == 100) {
            pd.close();
          }
        },
        cancelToken: token,
      );

      if (response.statusCode == 200) {
        return filePath;
      } else {
        CustomSnackBar()
            .snackBarError("${stctrl.lang["Error downloading file"]}");
        return null;
      }
    } catch (e) {
      token?.cancel();
      pd.close();
      CustomSnackBar()
          .snackBarError("${stctrl.lang["Error downloading file"]}");
      print(e.toString());
      return null; // Ensure the method returns null on error
    } finally {
      isDownloading(false);
      pd.close();
    }
  }
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
