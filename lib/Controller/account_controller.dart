// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:untitled2/Service/RemoteService.dart';

class AccountController extends GetxController {
  var isLoading = false.obs;

  var loginMsg = "".obs;

  String tokenKey = "token";

  var loadToken = '';

  var token = "";

  GetStorage userToken = GetStorage();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  // call login api
  Future fetchUserLogin() async {
    try {
      isLoading(true);
      var login = await RemoteServices.login(email.text, password.text);

      if (login != null) {
        var data = login['data'];
        if (data != null) {
          var accessToken = data['access_token'];
          if (accessToken != null && accessToken is String) {
            token = accessToken;
            loginMsg.value = login['message']?.toString() ?? 'Login successful';
            if (token.isNotEmpty) {
              saveToken(token);
            }
          } else {
            loginMsg.value = 'Invalid authentication token received';
          }
        } else {
          loginMsg.value = 'Invalid response from server';
        }
      } else {
        loginMsg.value = 'Login failed. Please try again.';
      }

      return login;
    } catch (e) {
      loginMsg.value = 'Login failed: ${e.toString()}';
      return null;
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
}
