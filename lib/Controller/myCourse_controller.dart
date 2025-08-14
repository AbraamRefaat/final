// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/account_controller.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/my_course_details_tab_controller.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/NewControllerAndModels/models/my_course_model.dart';
import 'package:untitled2/Service/RemoteService.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

class MyCourseController extends GetxController {
  final AccountController accountController = Get.put(AccountController());
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final HomeController homeController = Get.put(HomeController());

  var myCourses = <MyCourseModel>[].obs;

  var isLoading = false.obs;
  var commentLoader = false.obs;

  var isMyCourseLoading = false.obs;

  var tokenKey = "token";

  var myCourseDetails = CourseMain().obs;

  var lessons = [].obs;

  var youtubeID = "".obs;

  var courseID = 1.obs;

  var totalCourseProgress = 0.obs;

  var selectedLessonID = 0.obs;

  final TextEditingController commentController = TextEditingController();

  final MyCourseDetailsTabController myCourseDetailsTabController =
      Get.put(MyCourseDetailsTabController());

  @override
  void onInit() {
    super.onInit();
    // Listen to login status changes
    ever(dashboardController.loggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchMyCourse();
      } else {
        myCourses.clear(); // Clear data on logout
      }
    });

    // Initial fetch if already logged in when controller is created
    if (dashboardController.loggedIn.value) {
      fetchMyCourse();
    }
  }

  Future<List<MyCourseModel>?> fetchMyCourse() async {
    String? token = await accountController.userToken.read(tokenKey);

    // Debug: Print the current Bearer token
    if (token != null && token.isNotEmpty) {
      print('🔗 CURRENT BEARER TOKEN: $token');
      print('🔗 Copy this for API testing: Bearer $token');
    } else {
      print('❌ No Bearer token found - you need to login first!');
    }

    try {
      isLoading(true);

      // Fetch basic enrolled courses list from my-courses API
      var basicCourses = await RemoteServices.fetchMyCourse(token ?? '');
      List<MyCourseModel> newCourses =
          List<MyCourseModel>.from(basicCourses ?? []);

      // Initialize detailedCourses list outside the conditional block
      List<MyCourseModel> detailedCourses = [];

      if (newCourses.isNotEmpty) {
        print(
            '📚 Fetching detailed information for ${newCourses.length} enrolled courses...');

        // Fetch detailed information for each course
        for (var basicCourse in newCourses) {
          try {
            print('🔍 Fetching details for course ID: ${basicCourse.id}');
            var courseDetails =
                await RemoteServices.getMyCourseDetails(basicCourse.id);

            if (courseDetails != null) {
              // Convert CourseMain to detailed MyCourseModel
              var detailedCourse = _createDetailedCourseModel(courseDetails);
              detailedCourses.add(detailedCourse);
              print(
                  '✅ Successfully fetched details for: ${detailedCourse.title}');
            } else {
              // If course details fetch fails, use basic course info
              detailedCourses.add(basicCourse);
              print(
                  '⚠️ Failed to fetch details for course ${basicCourse.id}, using basic info');
            }
          } catch (e) {
            print('❌ Error fetching details for course ${basicCourse.id}: $e');
            // If course details fetch fails, use basic course info
            detailedCourses.add(basicCourse);
          }
        }

        // Create a Set to track existing course IDs
        final existingCourseIds = <String>{};
        existingCourseIds
            .addAll(myCourses.map((course) => course.id.toString()));

        // Filter out duplicates based on ID and add new courses
        final uniqueCourses = <MyCourseModel>[];
        for (var course in detailedCourses) {
          if (!existingCourseIds.contains(course.id.toString())) {
            uniqueCourses.add(course);
            existingCourseIds.add(course.id.toString());
          }
        }

        // Update the RxList with unique detailed courses
        myCourses.addAll(uniqueCourses);

        print(
            '🎉 Successfully loaded ${uniqueCourses.length} detailed courses');
      } else {
        // If no courses are fetched, reset myCourses
        myCourses.value = [];
        print('📭 No enrolled courses found');
      }

      return detailedCourses;
    } catch (e, t) {
      print('$e');
      print('$t');
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Helper method to convert CourseMain to detailed MyCourseModel
  MyCourseModel _createDetailedCourseModel(CourseMain courseDetails) {
    // Extract title from courseDetails
    String title = courseDetails.title ?? "Unknown Title";

    // Extract instructor information
    String instructorName = "Unknown Instructor";
    String instructorImage = "";
    if (courseDetails.user != null) {
      instructorName = courseDetails.user!.name ?? "Unknown Instructor";
      instructorImage = courseDetails.user!.image ?? "";
    }

    // Extract level title from courseLevel
    String levelTitle = "";
    int? levelId;
    if (courseDetails.courseLevel != null) {
      levelTitle = courseDetails.courseLevel!.title ?? "";
      levelId = courseDetails.courseLevel!.id;
    }

    // Calculate total chapters and lessons
    int totalChapters = courseDetails.chapters?.length ?? 0;
    int totalLessons = courseDetails.lessons?.length ?? 0;

    return MyCourseModel(
      id: courseDetails.id ?? 0,
      title: title,
      image: courseDetails.image ?? "",
      thumbnail: courseDetails.thumbnail ?? "",
      price: (courseDetails.price as num?)?.toDouble() ?? 0.0,
      discountPrice: (courseDetails.discountPrice as num?)?.toDouble() ?? 0.0,
      purchasePrice: (courseDetails.purchasePrice as num?)?.toDouble() ?? 0.0,
      assignedInstructor: instructorName,
      totalCompletePercentage: courseDetails.totalCompletePercentage ?? 0,
      slug: courseDetails.slug,
      duration: courseDetails.duration?.toString(),
      langId: courseDetails.langId,
      categoryId: courseDetails.categoryId,
      userId: courseDetails.userId,
      level: levelId,
      totalEnrolled: courseDetails.totalEnrolled,
      instructorName: instructorName,
      instructorImage: instructorImage,
      levelTitle: levelTitle,
      totalChapters: totalChapters,
      totalLessons: totalLessons,
    );
  }

  // get course details
  Future getCourseDetails() async {
    try {
      isMyCourseLoading(true);
      await RemoteServices.getMyCourseDetails(courseID.value).then((value) {
        myCourseDetails.value = value ?? CourseMain();
      });
      return myCourseDetails.value;
    } catch (e, t) {
      print('$e');
      print('$t');
    } finally {
      isMyCourseLoading(false);
      homeController.isCourseBought(false);
    }
  }

  Future<List<Lesson>?> getLessons(int courseId, dynamic chapterId) async {
    try {
      Uri topCatUrl =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/get-course-details/$courseId');

      // Create headers with ApiKey as specified in user's API collection
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      print('📤 Fetching lessons for course: $topCatUrl');

      var response = await http.get(topCatUrl, headers: headers);

      print('📥 Lessons response status: ${response.statusCode}');
      print('📥 Lessons response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']['lessons']);
          var lessons = List<Lesson>.from(
                  json.decode(courseData).map((x) => Lesson.fromJson(x)))
              .where((element) =>
                  int.parse(element.chapterId.toString()) ==
                  int.parse(chapterId.toString()))
              .toList();
          print(
              '✅ Successfully loaded ${lessons.length} lessons for chapter $chapterId');
          return lessons;
        } else {
          print('⚠️ Lessons API returned success=false or null data');
          return null;
        }
      } else {
        print('❌ Failed to fetch lessons: ${response.statusCode}');
        return null;
      }
    } catch (e, t) {
      print('❌ Exception fetching lessons: $e');
      print('❌ Stack trace: $t');
    } finally {}
    return null;
  }

  void submitComment(courseId, comment) async {
    commentLoader.value = true;
    String token = await accountController.userToken.read(tokenKey);

    var postUri = Uri.parse(baseUrl + '/comment');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['$authHeader'] = '$isBearer' + '$token';

    request.fields['course_id'] = courseId.toString();
    request.fields['comment'] = comment;
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == false) {
          commentLoader.value = false;
          CustomSnackBar().snackBarError(jsonString['message']);
        } else {
          commentLoader.value = false;
          CustomSnackBar().snackBarSuccess(jsonString['message']);

          getCourseDetails();
          commentController.text = "";
          myCourseDetailsTabController.controller?.animateTo(2);
        }
        return response.body;
      });
    }).catchError((err) {
      commentLoader.value = false;
      print('error : ' + err.toString());
    }).whenComplete(() {});
  }

  @override
  void onClose() {
    commentController.clear();
    super.onClose();
  }
}
