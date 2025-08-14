// course_by_category_id_new_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';

class CourseByCategoryIdNewController extends GetxController {
  var isLoading = true.obs;
  var courses = <Course>[].obs;

  Future<void> fetchCourses(int categoryId) async {
    isLoading.value = true;
    final response = await http
        .get(Uri.parse('${baseUrl}/get-all-courses?category=$categoryId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        courses.value = (data['data'] as List)
            .map((course) => Course.fromJson(course))
            .toList();
      }
    } else {
      // Handle error
      Get.snackbar('Error', 'Failed to load courses');
    }
    isLoading.value = false;
  }
}
