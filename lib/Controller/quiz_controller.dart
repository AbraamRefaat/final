// Dart imports:
// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Model/Quiz/MyQuizResultsModel.dart';
import 'package:untitled2/Model/Quiz/QuizStartModel.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';
import 'package:untitled2/NewControllerAndModels/models/my_quiz_model.dart';
import 'package:untitled2/Service/quiz_service.dart';
import 'package:untitled2/Model/Quiz/Quiz.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

import 'dashboard_controller.dart';

class QuizController extends GetxController {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  final TextEditingController commentController = TextEditingController();

  var isLoading = false.obs;
  var enrollLoader = false.obs;

  var isQuizLoading = false.obs;

  var cartAdded = false.obs;

  var isQuizBought = false.obs;

  var allClass = <Course>[].obs;

  var allMyQuiz = <MyQuizModel>[].obs;

  var allClassText = "${stctrl.lang["All Quiz"]}".obs;

  var courseFiltered = false.obs;

  GetStorage userToken = GetStorage();

  var tokenKey = "token";

  var courseID = 1.obs;

  var quizDetails = CourseMain().obs;

  var myQuizDetails = CourseMain().obs;

  var myQuizResult = MyQuizResultsModel().obs;

  var quizStart = QuizStartModel().obs;

  var isQuizStarting = false.obs;

  final TextEditingController reviewText = TextEditingController();

  var lessonQuizId = 1.obs;

  var selectedLessonID = 0.obs;

  RxBool isPurchasingIAP = false.obs;

  var quizHistory = <dynamic>[].obs;
  var isQuizHistoryLoading = false.obs;

  // Add observable for all quiz results
  var allQuizResults = <dynamic>[].obs;
  var isAllQuizResultsLoading = false.obs;

  // Add setter for course ID with debugging
  void setCourseID(int id) {
    print('🔧 Setting course ID in quiz controller: $id');
    courseID.value = id;
    print('🔧 Course ID set to: ${courseID.value}');
  }

  // Add getter for course ID with debugging
  int get getCourseID {
    print('🔍 Getting course ID from quiz controller: ${courseID.value}');
    return courseID.value;
  }

  void fetchAllClass() async {
    try {
      isLoading(true);
      // Use the new QuizService for better consistency
      var courses = await QuizService.getAllQuizzes();
      if (courses != null) {
        allClass.value = courses;
      }
    } finally {
      isLoading(false);
    }
  }

  Future getQuizDetails({int? id}) async {
    String token = await userToken.read(tokenKey);
    try {
      isQuizLoading(true);

      // For quiz courses (type=2), use getCourseDetails
      // For regular courses with lesson quizzes, use getCourseDetails and extract lesson info
      var value = await QuizService.getCourseDetails(id ?? courseID.value);

      if (value != null) {
        if (token != null) {
          cartAdded(false);
          if (value.enrolls != null) {
            isQuizBought(false);
            value.enrolls?.forEach((element) {
              if (element.userId == dashboardController.profileData.id) {
                isQuizBought(true);
              }
            });
          }
        }
      }
      quizDetails.value = value ?? CourseMain();
      return quizDetails.value;
    } finally {
      isQuizLoading(false);
    }
  }

  Future<bool> buyNow(String courseId) async {
    Uri addToCartUrl = Uri.parse(baseUrl + '/buy-now');
    var token = userToken.read(tokenKey);
    var response = await http.post(
      addToCartUrl,
      body: jsonEncode({'id': courseId}),
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var message = jsonEncode(jsonString['message']);

      CustomSnackBar().snackBarSuccess(message);

      final QuizController myQuizController =
          Get.find<QuizController>(); // Use find instead of put

      myQuizController.allMyQuiz.clear();
      myQuizController.allClassText.value = "${stctrl.lang["My Quiz"]}";
      myQuizController.courseFiltered.value = false;
      await myQuizController.fetchAllMyQuiz();

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

      allMyQuiz.value = [];
      await fetchAllMyQuiz();

      return true;
    } else {
      return false;
    }
  }

  Future getMyQuizDetails() async {
    try {
      isQuizLoading(true);
      // Use the new QuizService for getting course details (which includes quiz info)
      var value = await QuizService.getCourseDetails(courseID.value);
      myQuizDetails.value = value ?? CourseMain();
      await getMyQuizResults();
      return myQuizDetails.value;
    } finally {
      isQuizLoading(false);
    }
  }

  Future getMyQuizResults() async {
    String token = await userToken.read(tokenKey);
    try {
      isQuizLoading(true);
      // Use the new QuizService for getting quiz results with correct parameters
      var value = await QuizService.getQuizResult(
        token: token,
        courseId: myQuizDetails.value.id ?? 0,
        quizId: myQuizDetails.value.quizId ?? 0,
      );
      myQuizResult.value = value ?? MyQuizResultsModel();
      return myQuizResult.value;
    } catch (e) {
      print('Error getting quiz results: $e');
      myQuizResult.value = MyQuizResultsModel();
      return myQuizResult.value;
    } finally {
      isQuizLoading(false);
    }
  }

  void submitCourseReview(courseId, review, rating) async {
    String token = await userToken.read(tokenKey);

    var postUri = Uri.parse(baseUrl + '/submit-review');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = ' $token';

    request.fields['course_id'] = courseId.toString();
    request.fields['review'] = review;
    request.fields['rating'] = rating.toString();

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == false) {
          CustomSnackBar().snackBarError(jsonString['message']);
        } else {
          CustomSnackBar().snackBarError(jsonString['message']);
          Get.back();
          getQuizDetails();
          reviewText.text = "";
        }
        return response.body;
      });
    }).catchError((err) {
      print('error : ' + err.toString());
    }).whenComplete(() {});
  }

  Future fetchAllMyQuiz() async {
    String token = await userToken.read(tokenKey) ?? '';

    try {
      isLoading(true);

      // Use the new QuizService for better consistency
      var fetchedQuizzes = await QuizService.getStudentQuizzes(token);

      // Ensure fetchedQuizzes is of type List<MyQuizModel>
      List<MyQuizModel> newQuizzes =
          List<MyQuizModel>.from(fetchedQuizzes ?? []);

      if (newQuizzes.isNotEmpty) {
        // Create a Set to track existing quiz IDs
        final existingQuizIds = <String>{};

        // Add existing quiz IDs to the Set
        existingQuizIds.addAll(allMyQuiz.map((quiz) => quiz.id.toString()));

        // Filter out duplicates based on ID and add new quizzes
        final uniqueQuizzes = <MyQuizModel>[];
        for (var quiz in newQuizzes) {
          if (!existingQuizIds.contains(quiz.id.toString())) {
            uniqueQuizzes.add(quiz);
            existingQuizIds.add(quiz.id.toString());
          }
        }

        // Update the RxList with unique quizzes
        allMyQuiz.addAll(uniqueQuizzes);
      } else {
        // If no quizzes are fetched, reset allMyQuiz
        allMyQuiz.clear();
      }
    } catch (e, t) {
      print('$e');
      print('$t');
    } finally {
      isLoading(false);
    }
  }

  /// Fetch all completed quiz results for the student
  Future fetchAllQuizResults() async {
    String token = await userToken.read(tokenKey) ?? '';

    try {
      isAllQuizResultsLoading(true);
      print('📚 Fetching student quizzes for archive...');

      // Use the QuizService to get student quizzes (Quiz Archive API)
      var results = await QuizService.getStudentQuizzes(token);

      if (results != null && results.isNotEmpty) {
        print('📚 Found ${results.length} student quizzes');
        allQuizResults.value = results;
      } else {
        print('📚 No student quizzes found');
        allQuizResults.clear();
      }
    } catch (e, t) {
      print('❌ Error fetching student quizzes: $e');
      print('❌ Stack trace: $t');
      allQuizResults.clear();
    } finally {
      isAllQuizResultsLoading(false);
    }
  }

  Future<bool> startQuiz() async {
    try {
      var returnValue = false;
      String token = await userToken.read(tokenKey);
      isQuizStarting(true);

      print('🎯 Starting quiz...');
      print('📝 Course ID: ${myQuizDetails.value.id}');
      print('🎯 Quiz ID: ${myQuizDetails.value.quizId}');

      // Use the new QuizService for starting quiz with correct parameters
      var value = await QuizService.startQuiz(
        token: token,
        courseId: myQuizDetails.value.id ?? 0,
        quizId: myQuizDetails.value.quizId ?? 0,
      );

      if (value?.result == true) {
        quizStart.value = value ?? QuizStartModel();
        returnValue = true;
        print('✅ Quiz started successfully!');
      } else {
        returnValue = false;
        print('❌ Quiz start failed');
      }

      return returnValue;
    } catch (e) {
      print('Error starting quiz: $e');
      return false;
    } finally {
      isQuizStarting(false);
    }
  }

  Future<bool> startQuizFromLesson() async {
    try {
      var returnValue = false;
      String token = await userToken.read(tokenKey);
      isQuizStarting(true);

      print('🎯 Starting quiz from lesson...');
      print('📝 Quiz ID: ${lessonQuizId.value}');
      print('📋 Lesson ID: ${selectedLessonID.value}');
      print('🔑 Token: ${token.substring(0, 20)}...');

      // Validate required parameters
      if (lessonQuizId.value <= 0) {
        print('❌ Invalid quiz ID: ${lessonQuizId.value}');
        return false;
      }

      if (selectedLessonID.value <= 0) {
        print('❌ Invalid lesson ID: ${selectedLessonID.value}');
        return false;
      }

      // Get the course ID from the parent course context
      // The lesson quiz details API doesn't return course ID properly
      // So we use the course ID that was set when navigating to this quiz
      int courseId = getCourseID; // Use the getter to track access
      int quizId = lessonQuizId.value;

      print('🔍 Using Course ID from parent context: $courseId');
      print('🔍 Using Quiz ID: $quizId');

      if (courseId <= 0) {
        print('❌ Invalid course ID from parent context: $courseId');
        print(
            '🔍 Trying to get course ID from lesson quiz details as fallback...');

        // Fallback: try to get course ID from lesson quiz details
        courseId = myQuizDetails.value.id ?? 0;
        print('🔍 Fallback Course ID from lesson quiz details: $courseId');

        if (courseId <= 0) {
          print('❌ Still invalid course ID: $courseId');
          return false;
        }
      }

      // Step 1: Load quiz details first to ensure we have questions
      print('📚 Loading quiz details for quiz ID: $quizId');
      var quizDetails =
          await QuizService.getLessonQuizDetailsByQuizId(quizId, token: token);
      if (quizDetails == null) {
        print('❌ Failed to load quiz details for quiz ID: $quizId');
        return false;
      }

      print('✅ Quiz details loaded successfully:');
      print('✅ - Quiz ID: ${quizDetails.id}');
      print('✅ - Quiz Title: ${quizDetails.title}');
      print('✅ - Questions Count: ${quizDetails.assign?.length ?? 0}');

      if (quizDetails.assign?.isEmpty ?? true) {
        print('❌ No questions found in quiz details');
        return false;
      }

      // Step 2: Start the quiz
      print('🚀 Starting quiz...');
      var value = await QuizService.startQuiz(
        token: token,
        courseId: courseId, // Use course ID from parent context
        quizId: quizId, // Use quiz ID from lesson
      );

      print('🔍 Quiz start response: $value');
      print('🔍 Result field: ${value?.result}');
      print('🔍 Data field: ${value?.data}');
      print('🔍 Data ID: ${value?.data?.id}');

      // Check for success in multiple ways:
      // 1. result field is true
      // 2. we have a valid data object with ID (indicates successful quiz start)
      bool isSuccess = false;

      if (value != null) {
        if (value.result == true) {
          isSuccess = true;
          print('✅ Success via result field = true');
        } else if (value.data != null && value.data!.id != null) {
          isSuccess = true;
          print('✅ Success via valid data object with ID = ${value.data!.id}');
        }
      }

      if (isSuccess) {
        quizStart.value = value!;

        // Step 3: Update myQuizDetails with the loaded quiz details
        // Create a CourseMain object with the quiz details
        var courseMain = CourseMain();
        courseMain.quiz = quizDetails;
        courseMain.id = courseId;
        courseMain.title = quizDetails.title;
        myQuizDetails.value = courseMain;

        returnValue = true;
        print('✅ Quiz started successfully!');
        print('✅ Quiz details updated in myQuizDetails');
      } else {
        returnValue = false;
        print('❌ Quiz start failed - API returned result=${value?.result}');
        print('❌ No valid data found: ${value?.data}');
      }

      return returnValue;
    } catch (e) {
      print('💥 Error starting quiz from lesson: $e');
      return false;
    } finally {
      isQuizStarting(false);
    }
  }

  Future<Quiz?> getLessonQuizDetails(int lessonId) async {
    try {
      print('🔍 Getting lesson quiz details for lesson ID: $lessonId');
      int courseId = getCourseID;
      var quiz = await QuizService.getLessonQuizDetails(courseId, lessonId);
      if (quiz != null) {
        print('✅ Successfully loaded lesson quiz details');
        print('🔍 Quiz ID: ${quiz.id}');
        print('🔍 Quiz Title: ${quiz.title}');
        print('🔍 Questions Count: ${quiz.assign?.length ?? 0}');
        return quiz;
      } else {
        print('❌ No quiz found for lesson $lessonId');
        return null;
      }
    } catch (e) {
      print('💥 Error getting lesson quiz details: $e');
      return null;
    }
  }

  /// NEW: Get Quiz History
  /// Uses the new Quiz History API
  Future getQuizHistory(int quizId) async {
    String token = await userToken.read(tokenKey) ?? '';
    try {
      isQuizHistoryLoading(true);
      var history =
          await QuizService.getQuizHistory(token: token, quizId: quizId);
      if (history != null) {
        quizHistory.assignAll(history);
      } else {
        quizHistory.clear();
      }
      return quizHistory;
    } catch (e, t) {
      print('Error fetching quiz history: $e');
      print('StackTrace: $t');
      quizHistory.clear();
    } finally {
      isQuizHistoryLoading(false);
    }
  }

  void submitComment(courseId, comment) async {
    String token = await userToken.read(tokenKey);

    var postUri = Uri.parse(baseUrl + '/comment');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = ' $token';

    request.fields['course_id'] = courseId.toString();
    request.fields['comment'] = comment;
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == false) {
          CustomSnackBar().snackBarError(jsonString['message']);
        } else {
          CustomSnackBar().snackBarSuccess(jsonString['message']);
          getMyQuizDetails();
          commentController.text = "";
        }
        return response.body;
      });
    }).catchError((err) {
      print('error : ' + err.toString());
    }).whenComplete(() {});
  }

  // Add method to find lessons with quizzes
  Future<void> findLessonsWithQuizzes(List<int> lessonIds) async {
    print('🔍 Testing lessons for quizzes: $lessonIds');
    int courseId = getCourseID;
    for (int lessonId in lessonIds) {
      try {
        var quiz = await QuizService.getLessonQuizDetails(courseId, lessonId);
        if (quiz != null) {
          print('✅ Lesson $lessonId has a quiz!');
          print('🔍 Quiz title: ${quiz.title}');
          print('🔍 Questions count: ${quiz.assign?.length ?? 0}');
        } else {
          print('❌ Lesson $lessonId has no quiz');
        }
      } catch (e) {
        print('💥 Error testing lesson $lessonId: $e');
      }
    }
  }

  Future<void> startLessonQuiz(int courseId, int lessonId) async {
    try {
      String token = await userToken.read(tokenKey);
      // 1. Get course details
      final course = await QuizService.getCourseDetails(courseId);
      final matchingLessons = (course?.lessons ?? [])
          .where((l) => l.id == lessonId && l.quizId != null)
          .toList();
      if (matchingLessons.isEmpty) {
        throw Exception('No quiz found for this lesson');
      }
      final lesson = matchingLessons.first;
      // 3. Get quiz details
      final quiz = await QuizService.getLessonQuizDetailsByQuizId(
          lesson.quizId!,
          token: token);
      if (quiz == null) {
        throw Exception('Failed to load quiz details');
      }
      // 4. Start quiz
      final quizStart = await QuizService.startQuiz(
        token: token,
        courseId: courseId,
        quizId: lesson.quizId!,
      );
      if (quizStart == null || quizStart.data == null) {
        throw Exception('Failed to start quiz');
      }
      // 5. Navigate to quiz view (replace with your navigation logic)
      // Get.to(() => QuizView(courseId: courseId, quizId: lesson.quizId!, quizTestId: quizStart.data!.id));
      print('Quiz started! QuizTestId: ${quizStart.data!.id}');
    } catch (e) {
      print('Error starting lesson quiz: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllClass();
    // Listen to login status changes
    ever(dashboardController.loggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchAllMyQuiz();
      } else {
        allMyQuiz.clear(); // Clear data on logout
      }
    });

    // Initial fetch if already logged in when controller is created
    if (dashboardController.loggedIn.value) {
      fetchAllMyQuiz();
    }
  }
}
