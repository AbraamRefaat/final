// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/User/User.dart';
import 'package:untitled2/Service/RemoteService.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  PersistentTabController persistentTabController =
      PersistentTabController(initialIndex: 0);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  var loginReturn = " ";
  var token = "";
  var tokenKey = "token";
  GetStorage userToken = GetStorage();

  var loggedIn = false.obs;

  String? loadToken;

  final TextEditingController phone =
      TextEditingController(); // Added for phone login
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final TextEditingController registerName = TextEditingController();
  final TextEditingController registerFullName = TextEditingController();
  final TextEditingController registerEmail = TextEditingController();
  final TextEditingController registerStudentPhone = TextEditingController();
  final TextEditingController registerPassword = TextEditingController();
  final TextEditingController registerConfirmPassword = TextEditingController();
  final TextEditingController registerStudentWhatsApp = TextEditingController();
  final TextEditingController registerGuardianNumber = TextEditingController();
  final TextEditingController registerStudentCode = TextEditingController();

  // Study type selection
  var selectedStudyType = "online".obs;
  var showStudentCode = false.obs;

  var isLoading = false.obs;

  var loginMsg = "".obs;

  var profileData = User();

  var isRegisterScreen = false.obs;

  void changeTabIndex(int index) async {
    Get.focusScope?.unfocus();
    // persistentTabController.index = index;
    // final PersistentTabController tabIndexController =
    // PersistentTabController(initialIndex: 0);
    if (Platform.isIOS) {
      // Removed automatic drawer opening for account tab (index 3)
      // since we now have a dedicated AccountPage
    } else {
      // Removed automatic drawer opening for account tab (index 3)
      // since we now have a dedicated AccountPage
      if (index == 1) {
        if (loggedIn(true)) {}
      }
    }

    checkToken();
  }

  Future<void> loadUserToken() async {
    loadToken = await loadData();
    if (loadToken != null) {
      var toke = await userToken.read(tokenKey);
      checkToken();
      isLoading(false);
      return toke;
    } else {
      await userToken.remove(tokenKey);
    }
  }

  Future<String?> loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(tokenKey);
  }

  Future<void> checkToken() async {
    String? token = userToken.read(tokenKey);

    if (token != null && token.isNotEmpty) {
      // Token exists, let's validate it
      var user = await RemoteServices.getProfile(token);
      if (user != null) {
        // Token is valid
        profileData = user;
        loggedIn.value = true;
      } else {
        // Token is invalid or API failed
        await removeToken(
            'token'); // This clears the token and sets loggedIn to false
      }
    } else {
      loggedIn.value = false;
    }
    update();
  }

  // call login api
  Future fetchUserLogin() async {
    try {
      isLoading(true);
      var login = await RemoteServices.login(
          phone.text, password.text); // Changed from email.text to phone.text
      if (login != null) {
        // Handle V2 API response structure safely
        var data = login['data'];
        if (data != null) {
          var accessToken = data['access_token'];
          if (accessToken != null && accessToken is String) {
            token = accessToken;
            loginMsg.value = login['message']?.toString() ?? 'Login successful';

            if (token.length > 5) {
              await saveToken(token);
              await loadUserToken();
              await setupNotification();
              // await stctrl.getLanguage();
            }
            return login;
          } else {
            loginMsg.value = "Invalid response from server";
            Get.snackbar(
              "Login Error",
              "Invalid authentication token received",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              borderRadius: 5,
            );
          }
        } else {
          loginMsg.value = "Login failed - invalid response";
          Get.snackbar(
            "Login Error",
            "Server returned invalid response",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            borderRadius: 5,
          );
        }
      } else {
        loginMsg.value = "Login failed - please try again";
      }
    } catch (e) {
      loginMsg.value = "Login failed: ${e.toString()}";
      Get.snackbar(
        "Login Error",
        "An error occurred during login: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 5,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<bool> socialLogin(Map data) async {
    try {
      Uri loginUrl = Uri.parse(baseUrl + '/social-login');

      var body = json.encode(data);
      var response = await http.post(loginUrl, headers: header(), body: body);
      var jsonString = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var responseData = jsonString['data'];
        if (responseData != null) {
          var accessToken = responseData['access_token'];
          if (accessToken != null && accessToken is String) {
            token = accessToken;

            if (token.length > 5) {
              await userToken.write("method", "${data['provider']}");

              await saveToken(token);
              await loadUserToken();
              await setupNotification();
              // await stctrl.getLanguage();

              return true;
            }
          }
        }
        return false;
      } else if (response.statusCode == 401) {
        Get.snackbar(
          stctrl.lang["Invalid Credentials"] ?? "Invalid Credentials",
          stctrl.lang["Wrong Email or Password. Please try again"] ??
              "Wrong credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
      } else {
        var message = jsonString['message']?.toString() ?? "Login failed";
        Get.snackbar(
          stctrl.lang["Something went wrong!"] ?? "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Login Error",
        "An error occurred during social login: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 5,
      );
    }

    return false;
  }

  void showRegisterScreen() {
    isRegisterScreen.value = !isRegisterScreen.value;
  }

  void selectStudyType(String type) {
    selectedStudyType.value = type;
    showStudentCode.value = type == "offline";
  }

  Future fetchUserRegister() async {
    try {
      isLoading(true);
      var login = await RemoteServices.register(
        registerFullName.text,
        registerStudentPhone.text,
        registerPassword.text,
        registerConfirmPassword.text,
        registerStudentWhatsApp.text,
        registerGuardianNumber.text,
        selectedStudyType.value,
        showStudentCode.value ? registerStudentCode.text : "",
      );
      if (login != null) {
        if (login['success'] == true) {
          showRegisterScreen();

          registerName.clear();
          registerStudentPhone.clear();
          registerPassword.clear();
          registerConfirmPassword.clear();
          registerStudentWhatsApp.clear();
          registerGuardianNumber.clear();
          registerStudentCode.clear();
          selectedStudyType.value = "online";
          showStudentCode.value = false;

          Get.snackbar(
            login['message'],
            "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 5,
          );
        }

        return login;
      }
    } catch (e, t) {
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveToken(String msg) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (msg.length > 5) {
      await preferences.setString(tokenKey, msg);
      await userToken.write(tokenKey, msg);
    } else {}
  }

  Future<void> removeToken(String msg) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove(tokenKey);
      await userToken.remove(tokenKey);
      loggedIn.value = false;
      loginMsg.value = stctrl.lang['Logged out'] ?? 'Logged out';
      update();
      Get.snackbar(
        stctrl.lang['Done'] ?? 'Done',
        stctrl.lang['Logged out'] ?? 'Logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        borderRadius: 5,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<User?> getProfileData() async {
    String? token = userToken.read(tokenKey);
    if (token == null) {
      return null;
    }
    try {
      var products = await RemoteServices.getProfile(token);
      profileData = products ?? User();
      return products;
    } finally {}
  }

  String _firebaseAppToken = '';
  Future<void> setupNotification() async {
    // Firebase messaging temporarily disabled
    print('Firebase messaging setup skipped');
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement?.text ?? '';

    return parsedString;
  }

  Future sendTokenToServer(String notificationToken) async {
    await getProfileData();
    String token = await userToken.read(tokenKey);
    final response = await http.post(
        Uri.parse(baseUrl +
            '/set-fcm-token?id=${profileData.id}&token=$notificationToken'),
        headers: header(token: token));
    if (response.statusCode == 200) {
      print('token updated : $notificationToken');
    } else {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove(tokenKey);
      await userToken.remove(tokenKey);
      checkToken();
      loginMsg.value = stctrl.lang["Logged out"] ?? "Logged out";
      update();
      Get.snackbar(
        stctrl.lang["Status"] ?? "Status",
        stctrl.lang["Logged out"] ?? "Logged out",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 5,
      );
      throw Exception('Failed to load');
    }
  }

  var obscurePass = true.obs;
  var obscureNewPass = true.obs;
  var obscureConfirmPass = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize loginMsg to prevent null errors
    loginMsg.value = "";
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      isLoading(true);

      // Test API connectivity first
      await RemoteServices.testApiConnectivity();

      await checkToken();
      if (loggedIn.value) {
        await setupNotification();
      }
      if (isDemo) {
        email.text = 'student@infixedu.com';
        password.text = '12345678';
      }
    } catch (e) {
      print('Error during app initialization: $e');
      loggedIn.value = false;
      loginMsg.value = "";
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    print('Log out mazed Vai:::::');
    super.onClose();
  }
}
