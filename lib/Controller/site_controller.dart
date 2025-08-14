import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/Model/Settings/Languages.dart';

import '../Model/Settings/LanguageData.dart';

class SiteController extends GetxController {
  GetStorage userToken = GetStorage();

  String tokenKey = "token";

  // Getter for DashboardController to avoid circular dependency
  DashboardController get dashboardController =>
      Get.find<DashboardController>();

  RxString code = "en".obs; // Default to English

  RxBool isLanguageLoading = false.obs;

  final lang = RxMap({
    // Default English translations to prevent null errors
    "Sign In": "Sign In",
    "Email": "Email",
    "Password": "Password",
    "Login": "Login",
    "Invalid Credentials": "Invalid Credentials",
    "Wrong Email or Password. Please try again":
        "Wrong Email or Password. Please try again",
    "Something went wrong!": "Something went wrong!",
    "Status": "Status",
    "Done": "Done",
    "Logged out": "Logged out",
    "Not verified": "Not verified",
    "Verify Your Email Address": "Verify Your Email Address",
    "Before proceeding, please check your email for a verification link Login in Using that Link.":
        "Before proceeding, please check your email for a verification link Login in Using that Link.",
    "Login Cancelled": "Login Cancelled",
  });

  final rtl = RxBool(false);

  Rx<Language> selectedLanguage = Language().obs;

  RxList<Language> languages = <Language>[].obs;

  Future getLanguage({String? langCode}) async {
    try {
      // Use Get.find() to get the DashboardController
      final dashboardController = Get.find<DashboardController>();
      dashboardController.isLoading(true);

      var token = userToken.read(tokenKey);

      String url = langCode == null
          ? "$baseUrl/get-lang"
          : "$baseUrl/get-lang?code=$langCode";
      print('Language URL: $url');

      var response = await http.get(
        Uri.parse(url),
        headers: header(token: token),
      );

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']);
          final data = LanguageData.fromJson(json.decode(courseData));

          code.value = data.code ?? 'en';
          if (data.lang != null) {
            // Convert Map<String, dynamic> to Map<String, String>
            final Map<String, String> langMap = {};
            data.lang!.forEach((key, value) {
              langMap[key] = value?.toString() ?? key;
            });
            lang.value = langMap;
          }

          if (data.rtl == "1") {
            rtl.value = true;
          } else {
            rtl.value = false;
          }

          Get.updateLocale(Locale('${code.value}'));
        }
      } else {
        print('Failed to load language: ${response.statusCode}');
        code.value = "en";
      }
    } catch (e) {
      print('Error loading language: $e');
      code.value = "en";
    } finally {
      try {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.isLoading(false);
      } catch (e) {
        print('Error accessing dashboard controller: $e');
      }
    }
  }

  Future<LanguageList?> getAllLanugages() async {
    try {
      var token = userToken.read(tokenKey);
      Uri myAddressUrl = Uri.parse(baseUrl + '/languages');
      var response = await http.get(
        myAddressUrl,
        headers: header(token: token),
      );
      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['data'] != null) {
          return LanguageList.fromJson(jsonString['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting all languages: $e');
      return null;
    }
  }

  Future setLanguage({String? langCode}) async {
    try {
      // Use Get.find() to get the DashboardController
      final dashboardController = Get.find<DashboardController>();
      dashboardController.isLoading(true);

      var token = userToken.read(tokenKey);
      var response = await http.post(Uri.parse(baseUrl + '/set-lang'),
          body: jsonEncode({
            'lang': langCode,
          }),
          headers: header(token: token));

      if (response.statusCode == 200) {
        await getLanguage();

        Get.updateLocale(Locale('${code.value}'));

        dashboardController.isLoading(false);
      } else {
        dashboardController.isLoading(false);
        code.value = "en";
      }
    } catch (e) {
      print('Error setting language: $e');
      try {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.isLoading(false);
      } catch (e) {
        print('Error accessing dashboard controller: $e');
      }
      code.value = "en";
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with safe defaults
    languages.value = [
      Language(id: 1, code: 'en', name: 'English', native: 'English', rtl: 0),
      Language(id: 2, code: 'ar', name: 'Arabic', native: 'العربية', rtl: 1),
    ];

    // Load language after initialization
    Future.delayed(Duration(milliseconds: 100), () {
      getLanguage();
      getAllLanugages();
    });
  }
}
