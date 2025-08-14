// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/Model/ModelTopCategory.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';
import 'package:untitled2/Service/RemoteService.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

class HomeController extends GetxController {
  var selectedLessonID = 0.obs;

  var isLoading = false.obs;

  var isCourseLoading = false.obs;

  var cartAdded = false.obs;

  var isCourseBought = false.obs;

  RxList<TopCategory> topCatList = <TopCategory>[].obs;

  var popularCourseList = <Course>[].obs;

  var allClassesList = <Course>[].obs;

  var allCourse = <Course>[].obs;

  var courseDetails = CourseMain().obs;

  GetStorage userToken = GetStorage();

  var filterDrawer = GlobalKey<ScaffoldState>();

  final DashboardController dashboardController =
      Get.put(DashboardController());

  var tokenKey = "token";

  final TextEditingController reviewText = TextEditingController();

  var allCourseText = "${stctrl.lang["All Courses"]}".obs;

  var courseFiltered = false.obs;

  var courseID = 1.obs;

  var freeCourse = false.obs;

  RxBool isPurchasingIAP = false.obs;

  // Cache for filtered courses to improve reliability and speed
  Map<String, List<Course>> _filteredCourseCache = {};

  bool shouldForceReload = false;

  @override
  void onInit() {
    super.onInit();
    createManualCategories(); // Create manual categories instead of fetching from API
    fetchPopularCourse();
    fetchAllClass();
    fetchAllCourse();
  }

  // Create manual categories for secondary levels
  void createManualCategories() {
    topCatList.clear();
    topCatList.addAll([
      TopCategory(
        id: 1,
        name: 'First Secondary',
        courseCount: 0, // Not displayed anymore
      ),
      TopCategory(
        id: 2,
        name: 'Second Secondary',
        courseCount: 0, // Not displayed anymore
      ),
      TopCategory(
        id: 3,
        name: 'Third Secondary',
        courseCount: 0, // Not displayed anymore
      ),
    ]);
  }

  // Optimized course filtering with better performance
  Future<List<Course>> getCoursesForLevel(String levelName) async {
    // Check cache first for faster subsequent loads
    if (_filteredCourseCache.containsKey(levelName)) {
      return _filteredCourseCache[levelName]!;
    }

    List<Course> filteredCourses = [];

    try {
      // Fetch courses with level information included in the response
      var freshCourses = await RemoteServices.fetchallCourse();
      if (freshCourses == null || freshCourses.isEmpty) {
        return [];
      }

      // Limit the number of API calls to improve performance
      int maxCoursesToCheck = 20; // Only check first 20 courses
      int checkedCount = 0;

      for (var course in freshCourses) {
        if (checkedCount >= maxCoursesToCheck) break;

        try {
          // Get course details with timeout to prevent hanging
          CourseMain? courseDetails =
              await RemoteServices.getCourseDetails(course.id)
                  .timeout(Duration(seconds: 5));

          String courseLevel = '';
          if (courseDetails?.courseLevel?.title != null) {
            courseLevel = courseDetails!.courseLevel!.title!;
          }

          // Simple exact matching for reliability
          if ((levelName == 'First Secondary' && courseLevel == 'Beginner') ||
              (levelName == 'Second Secondary' &&
                  courseLevel == 'Intermediate') ||
              (levelName == 'Third Secondary' && courseLevel == 'Advance')) {
            filteredCourses.add(course);
          }

          checkedCount++;
        } catch (e) {
          // Skip this course if there's an error
          checkedCount++;
          continue;
        }
      }

      // Cache the results for faster subsequent loads
      _filteredCourseCache[levelName] = filteredCourses;
    } catch (e) {
      // If everything fails, return empty list
      return [];
    }

    return filteredCourses;
  }

  // Clear cache when courses are refreshed
  void clearFilterCache() {
    _filteredCourseCache.clear();
  }

  // call api for top category
  void fetchTopCat() async {
    try {
      isLoading(true);
      var products = await RemoteServices.fetchTopCat();
      if (products != null) {
        topCatList.value = products;
      }
    } finally {
      isLoading(false);
    }
  }

// call api for popular course
  void fetchPopularCourse() async {
    try {
      isLoading(true);
      var products = await RemoteServices.fetchpopularCat();
      if (products != null) {
        popularCourseList.value = products;
      }
    } finally {
      isLoading(false);
    }
  }

  // call api for All course
  void fetchAllCourse() async {
    try {
      isLoading(true);
      clearFilterCache(); // Clear cache when refreshing courses
      var products = await RemoteServices.fetchallCourse();
      if (products != null) {
        allCourse.value = products;
      }
    } finally {
      isLoading(false);
    }
  }

  void fetchAllClass() async {
    try {
      isLoading(true);
      var products = await RemoteServices.fetchPopularClasses();
      if (products != null) {
        allClassesList.value = products;
      }
    } finally {
      isLoading(false);
    }
  }

  Future<bool> buyNow(int courseId) async {
    Uri addToCartUrl = Uri.parse(baseUrl + '/buy-now');
    var token = userToken.read(tokenKey);
    var response = await http.post(
      addToCartUrl,
      body: jsonEncode({'id': courseId}),
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      print(response.body);
      var jsonString = jsonDecode(response.body);
      var message = jsonEncode(jsonString['message']);

      CustomSnackBar().snackBarSuccess(message);

      final MyCourseController myCoursesController =
          Get.put(MyCourseController());

      myCoursesController.myCourses.value = [];
      await myCoursesController.fetchMyCourse();

      return true;
    } else {
      return false;
    }
  }

  Future<bool> enrollIAP(int courseId) async {
    Uri addToCartUrl = Uri.parse(baseUrl + '/enroll-iap');
    var token = userToken.read(tokenKey);
    var response = await http.post(
      addToCartUrl,
      body: jsonEncode({'id': courseId}),
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var message = jsonEncode(jsonString['message']);
      print(message);

      // CustomSnackBar().snackBarSuccess(message);

      final MyCourseController myCoursesController =
          Get.put(MyCourseController());

      myCoursesController.myCourses.value = [];
      await myCoursesController.fetchMyCourse();

      return true;
    } else {
      return false;
    }
  }

  // get course details
  Future getCourseDetails() async {
    try {
      if (!shouldForceReload &&
          courseDetails.value.id == courseID.value &&
          courseDetails.value.id != 0) {
        // Already loaded
        return courseDetails.value;
      }
      isCourseLoading(true);
      print(
          '🔍 getCourseDetails called with courseID:  [32m${courseID.value} [0m');
      await RemoteServices.getCourseDetails(courseID.value).then((value) async {
        cartAdded(false);
        print(
            '📦 API returned course details: ID=${value?.id}, Title=${value?.title}');
        if (value?.enrolls != null) {
          isCourseBought(false);
          value?.enrolls?.forEach((element) {
            if (element.userId == dashboardController.profileData.id) {
              isCourseBought(true);
            }
          });
        }
        courseDetails.value = value ?? CourseMain();
        print(
            '✅ Course details set: ID=${courseDetails.value.id}, Title=${courseDetails.value.title}');
      });
      shouldForceReload = false;
      return courseDetails.value;
    } catch (e, t) {
      print('❌ Error in getCourseDetails: $e');
      print('❌ Stack trace: $t');
    } finally {
      isCourseLoading(false);
    }
  }

  void submitCourseReview(courseId, review, rating) async {
    String token = await userToken.read(tokenKey);

    var postUri = Uri.parse(baseUrl + '/submit-review');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['$authHeader'] = '$isBearer' + '$token';

    request.fields['course_id'] = courseId.toString();
    request.fields['review'] = review;
    request.fields['rating'] = rating.toString();

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == false) {
          CustomSnackBar().snackBarError(jsonString['message']);
        } else {
          Get.back();
          CustomSnackBar().snackBarSuccess(jsonString['message']);
          getCourseDetails();
          reviewText.text = "";
        }
        return response.body;
      });
    }).catchError((err) {
      print('error : ' + err.toString());
    }).whenComplete(() {});
  }

  Future<List<Lesson>?> getLessons(int courseId, int chapterId) async {
    var client = http.Client();

    try {
      Uri topCatUrl =
          Uri.parse(baseUrl + '/get-course-details/' + courseId.toString());
      var response = await client.get(topCatUrl);
      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var courseData = jsonEncode(jsonString['data']['lessons']);

        return List<Lesson>.from(
                json.decode(courseData).map((x) => Lesson.fromJson(x)))
            .where((element) => element.chapterId == chapterId)
            .toList();
      } else {
        return null;
      }
    } finally {}
  }

  void resetCourseDetails() {
    courseID.value = 0;
    courseDetails.value = CourseMain();
    isCourseBought.value = false;
    shouldForceReload = true;
  }
}
