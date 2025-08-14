import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/Config/app_config.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;

  // TextEditingController for managing input fields
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> updatePassword(String token) async {
    isLoading.value = true;
    try {
      var postUri = Uri.parse(baseUrl + '/change-password');

      var body = jsonEncode({
        'old_password': oldPasswordController.text,
        'new_password': newPasswordController.text,
        'confirm_password': confirmPasswordController.text,
      });

      var response = await http.post(
        postUri,
        headers: header(token: token),
        body: body,
      );

      var jsonString = jsonDecode(response.body);

      if (!jsonString['success']) {
        CustomSnackBar().snackBarError(jsonString['message']);
      } else {
        CustomSnackBar().snackBarSuccess(jsonString['message']);
        // Clear the token and fields if needed
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
    } catch (e) {
      print('Error: $e');
      CustomSnackBar().snackBarError("An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers when the controller is removed from memory
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
