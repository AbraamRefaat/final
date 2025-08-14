// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Model/Quiz/MyQuizResultsModel.dart';
import 'package:untitled2/Model/Quiz/QuizStartModel.dart';
import 'package:untitled2/Model/Quiz/QuestionResultModel.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';
import 'package:untitled2/NewControllerAndModels/models/my_quiz_model.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Model/Quiz/Quiz.dart';

class QuizService {
  /// API 1: All Quizzes
  /// GET /api/get-all-quizzes
  /// Headers: Accept: application/json, ApiKey: {apiKey}
  static Future<List<Course>?> getAllQuizzes() async {
    try {
      Uri url = Uri.parse(baseUrl + '/get-all-quizzes');

      var response = await http.get(url, headers: header());

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var courseData = jsonEncode(jsonString['data']);
        return List<Course>.from(
            json.decode(courseData).map((x) => Course.fromJson(x))).toList();
      } else {
        debugPrint(
            'Get all quizzes failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getAllQuizzes: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 2: Student Quizzes
  /// GET /api/my-quizzes
  /// Headers: Accept: application/json, ApiKey: {apiKey}, Authorization: Bearer {token}
  static Future<List<dynamic>?> getStudentQuizzes(String token) async {
    try {
      Uri url = Uri.parse('$baseUrl/my-quizzes');

      print('📚 Getting student quizzes (Quiz Archive API):');
      print('📍 URL: $url');

      // Use exact headers as specified in the API documentation
      Map<String, String> headers = {
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(url, headers: headers);

      print('📥 Student Quizzes Response Status: ${response.statusCode}');
      print('📥 Student Quizzes Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        // Check if the response has a data field
        if (jsonString['data'] != null) {
          return jsonString['data'] as List<dynamic>?;
        } else {
          // If no data field, return the entire response as a list
          return jsonString is List ? jsonString : [jsonString];
        }
      } else {
        debugPrint(
            'Get student quizzes failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getStudentQuizzes: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 3: Get Course Details (Website Exact Implementation)
  /// GET /api/get-course-details/{course_id}
  /// Headers: Authorization: Bearer {token}
  /// This returns course details including quiz information for quiz courses (type=2)
  static Future<CourseMain?> getCourseDetails(int courseId) async {
    try {
      // Use exact URL format as Postman example
      Uri url =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/get-course-details/$courseId');

      print('🔍 Getting course details from: $url');

      var response = await http.get(url, headers: header());

      print('🔍 Course details response status: ${response.statusCode}');
      print('🔍 Course details response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        print('🔍 Course details JSON: $jsonString');
        print('🔍 Success field: ${jsonString['success']}');
        print('🔍 Data exists: ${jsonString['data'] != null}');

        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']);
          var courseMain = CourseMain.fromJson(json.decode(courseData));

          print('🔍 Parsed CourseMain:');
          print('🔍 - Course ID: ${courseMain.id}');
          print('🔍 - Course Type: ${courseMain.type}');
          print('🔍 - Quiz ID: ${courseMain.quizId}');
          print('🔍 - Title: ${courseMain.title}');
          print('🔍 - Quiz object exists: ${courseMain.quiz != null}');
          print(
              '🔍 - Quiz assign (questions): ${courseMain.quiz?.assign?.length ?? 0} questions');

          return courseMain;
        } else {
          print('❌ Course details API returned success=false or no data');
          return null;
        }
      } else {
        debugPrint(
            'Get course details failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getCourseDetails: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 3.1: Quiz Details (Legacy - DO NOT USE FOR LESSON QUIZZES)
  /// GET /api/get-quiz-details/{id}
  /// Headers: Authorization: Bearer {token}
  /// WARNING: This should NOT be used for lesson quizzes. Use getLessonQuizDetailsByQuizId instead.
  static Future<CourseMain?> getQuizDetails(int quizId) async {
    try {
      Uri url = Uri.parse('$baseUrl/get-quiz-details/$quizId');

      print('🔍 [LEGACY] Getting quiz details from: $url');

      var response = await http.get(url, headers: header());

      print('🔍 Quiz details response status: ${response.statusCode}');
      print('🔍 Quiz details response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        print('🔍 Quiz details JSON: $jsonString');
        print('🔍 Quiz data exists: ${jsonString['data'] != null}');
        print('🔍 Quiz object exists: ${jsonString['data']?['quiz'] != null}');

        var courseData = jsonEncode(jsonString['data']);
        var courseMain = CourseMain.fromJson(json.decode(courseData));

        print('🔍 Parsed CourseMain:');
        print('🔍 - ID: ${courseMain.id}');
        print('🔍 - Title: ${courseMain.title}');
        print('🔍 - Quiz object: ${courseMain.quiz}');
        print(
            '🔍 - Quiz assign (questions): ${courseMain.quiz?.assign?.length ?? 0} questions');

        return courseMain;
      } else {
        debugPrint(
            'Get quiz details failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getQuizDetails: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 4: Start Quiz (Website Exact Implementation)
  /// POST /api/quiz-start/{course_id}/{quiz_id}
  /// Headers: Authorization: Bearer {token}, Content-Type: application/json
  /// Body: { "quiz_test_id": null }
  static Future<QuizStartModel?> startQuiz({
    required String token,
    required int courseId,
    required int quizId,
    int? quizTestId,
  }) async {
    try {
      // Use exact URL format as Postman example
      Uri url =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/quiz-start/$courseId/$quizId');

      // Prepare request body: only include quiz_test_id if provided
      Map<String, dynamic> body = {};
      if (quizTestId != null) {
        body['quiz_test_id'] = quizTestId;
      }

      // Use headers as per website (Bearer token, Accept, ApiKey)
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
      };

      print('🚀 Starting quiz (Website Exact Implementation):');
      print('📍 URL: $url');
      print('📍 Base URL from config: $baseUrl');
      print('🔑 Token: ${token.substring(0, 20)}...');
      print('📚 Course ID: $courseId');
      print('🎯 Quiz ID: $quizId');
      print('📤 Request Body: $body');
      print('📤 Headers: $headers');

      var response = await http.post(
        url,
        headers: headers,
        body: body.isNotEmpty ? jsonEncode(body) : null,
      );

      print('📥 Quiz Start Response Status: ${response.statusCode}');
      print('📥 Quiz Start Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        print('🔍 Parsed JSON: $jsonString');
        print('🔍 Result field: ${jsonString['result']}');
        print('🔍 Data field exists: ${jsonString['data'] != null}');

        var encodedString = jsonEncode(jsonString);
        var model = quizStartModelFromJson(encodedString);
        print('🔍 Model result field: ${model.result}');
        print('🔍 Model data field: ${model.data}');
        return model;
      } else {
        debugPrint('Start quiz failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in startQuiz: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 5: Submit Single Question (Website Exact Implementation)
  /// POST /api/quiz-single-submit
  /// Headers: Authorization: Bearer {token}, Accept: application/json, ApiKey: {apiKey}
  /// Body: { "quiz_test_id": 123, "assign_id": 456, "type": "M", "ans": [789], "focus_lost": 0 }
  static Future<bool> submitSingleQuestion({
    required String token,
    required int quizTestId,
    required int assignId,
    required String type,
    required dynamic answer,
    int focusLost = 0,
  }) async {
    try {
      // Use exact URL format as Postman example
      Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/api/quiz-single-submit');

      // Prepare request body exactly as website
      Map<String, dynamic> body = {
        "quiz_test_id": quizTestId,
        "assign_id": assignId,
        "type": type,
        "ans": answer,
        "focus_lost": focusLost,
      };

      print('📝 Submitting single question (Website Exact Implementation):');
      print('📍 URL: $url');
      print('🔍 Quiz Test ID: $quizTestId');
      print('🔍 Assign ID: $assignId');
      print('🔍 Type: $type');
      print('🔍 Answer: $answer');
      print('📤 Request Body: $body');

      // Use exact headers as website (Authorization, Accept, ApiKey)
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
      };

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Single Submit Response Status: ${response.statusCode}');
      print('📥 Single Submit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle empty response body (some APIs return empty body on success)
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print(
              '✅ Single Submit Success: Empty response body (likely success)');
          return true;
        }

        try {
          var jsonString = jsonDecode(response.body);
          print('🔍 Single Submit Success: ${jsonString['success']}');
          return jsonString['success'] == true;
        } catch (e) {
          print(
              '⚠️ JSON parsing error, but status is 200. Treating as success: $e');
          return true;
        }
      } else {
        debugPrint(
            'Submit single question failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in submitSingleQuestion: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// API 6: Final Quiz Submit (Website Exact Implementation)
  /// POST /api/quiz-final-submit
  /// Headers: Authorization: Bearer {token}, Accept: application/json, ApiKey: {apiKey}
  /// Body: { "quiz_test_id": 123, "type": ["M", "X"] }
  static Future<bool> submitFinalQuiz({
    required String token,
    required int quizTestId,
    required List<String> questionTypes,
  }) async {
    try {
      // Use exact URL format as Postman example
      Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/api/quiz-final-submit');

      // Prepare request body exactly as website
      Map<String, dynamic> body = {
        "quiz_test_id": quizTestId,
        "type": questionTypes,
      };

      print('🏁 Submitting final quiz (Website Exact Implementation):');
      print('📍 URL: $url');
      print('🔍 Quiz Test ID: $quizTestId');
      print('🔍 Question Types Array: $questionTypes');
      print('📤 Request Body: $body');
      print('📤 JSON Body: ${jsonEncode(body)}');

      // Use exact headers as website (Authorization, Accept, ApiKey)
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
        'Content-Type': 'application/json', // Add Content-Type for JSON
      };

      print('📤 Headers: $headers');

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Final Submit Response Status: ${response.statusCode}');
      print('📥 Final Submit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle empty response body (some APIs return empty body on success)
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('✅ Final Submit Success: Empty response body (likely success)');
          return true;
        }

        try {
          var jsonString = jsonDecode(response.body);
          print('🔍 Final Submit Success: ${jsonString['success']}');
          print('🔍 Final Submit Message: ${jsonString['message']}');
          return jsonString['success'] == true;
        } catch (e) {
          print(
              '⚠️ JSON parsing error, but status is 200. Treating as success: $e');
          return true;
        }
      } else {
        debugPrint(
            'Submit final quiz failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in submitFinalQuiz: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// API 7: Get Quiz Result (Website Exact Implementation)
  /// POST /api/quiz-result/{course_id}/{quiz_id}
  /// Headers: Authorization: Bearer {token}, Accept: application/json, ApiKey: {apiKey}
  static Future<MyQuizResultsModel?> getQuizResult({
    required String token,
    required int courseId,
    required int quizId,
  }) async {
    try {
      // Use exact URL format as Postman example
      Uri url =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/quiz-result/$courseId/$quizId');

      print('📊 Getting quiz result (Website Exact Implementation):');
      print('📍 URL: $url');
      print('🔍 Course ID: $courseId');
      print('🔍 Quiz ID: $quizId');

      // Use exact headers as website (Authorization, Accept, ApiKey)
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
      };

      print('📤 Headers: $headers');

      var response = await http.post(
        url,
        headers: headers,
      );

      print('📥 Quiz Result Response Status: ${response.statusCode}');
      print('📥 Quiz Result Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle empty response body (some APIs return empty body on success)
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('✅ Quiz Result Success: Empty response body (likely success)');
          return null; // Return null for empty response
        }

        try {
          var jsonString = jsonDecode(response.body);
          var courseData = jsonEncode(jsonString);
          return myQuizResultsModelFromJson(courseData);
        } catch (e) {
          print('⚠️ JSON parsing error for quiz result: $e');
          return null;
        }
      } else {
        debugPrint(
            'Get quiz result failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getQuizResult: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 8: Get All Quiz Results (Website Exact Implementation)
  /// POST /api/quiz-results
  /// Headers: Authorization: Bearer {token}, Content-Type: application/json
  static Future<List<dynamic>?> getAllQuizResults(String token) async {
    try {
      Uri url = Uri.parse('$baseUrl/quiz-results');

      print('📚 Getting all quiz results (Website Exact Implementation):');
      print('📍 URL: $url');

      // Use exact headers as website
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var response = await http.post(
        url,
        headers: headers,
      );

      print('📥 All Quiz Results Response Status: ${response.statusCode}');
      print('📥 All Quiz Results Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        return jsonString['data'] as List<dynamic>?;
      } else {
        debugPrint(
            'Get all quiz results failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getAllQuizResults: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 9: Quiz Result Preview (Website Exact Implementation)
  /// POST /api/quiz-result-preview/{quiz_id}
  /// Headers: Authorization: Bearer {token}, Content-Type: application/json
  static Future<QuizResultModel?> getQuestionResult({
    required String token,
    required int quizResultId,
  }) async {
    try {
      Uri url = Uri.parse('$baseUrl/quiz-result-preview/$quizResultId');

      print('📊 Getting quiz result preview (Website Exact Implementation):');
      print('📍 URL: $url');
      print('🔍 Quiz Result ID: $quizResultId');

      // Use exact headers as website
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var response = await http.post(
        url,
        headers: headers,
      );

      print('📥 Result Preview Response Status: ${response.statusCode}');
      print('📥 Result Preview Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var encodedString = jsonEncode(jsonString);
        return quizResultModelFromJson(encodedString);
      } else {
        debugPrint(
            'Get question result failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getQuestionResult: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API 10: Quiz History (Website Exact Implementation)
  /// POST /api/quiz-history/{quiz_id}
  /// Headers: Authorization: Bearer {token}, Content-Type: application/json
  static Future<List<dynamic>?> getQuizHistory({
    required String token,
    required int quizId,
  }) async {
    try {
      Uri url = Uri.parse('$baseUrl/quiz-history/$quizId');

      print('📚 Getting quiz history (Website Exact Implementation):');
      print('📍 URL: $url');
      print('🔍 Quiz ID: $quizId');

      // Use exact headers as website
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var response = await http.post(
        url,
        headers: headers,
      );

      print('📥 Quiz History Response Status: ${response.statusCode}');
      print('📥 Quiz History Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        return jsonString['data'] as List<dynamic>?;
      } else {
        debugPrint(
            'Get quiz history failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getQuizHistory: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// Helper method to safely get QuizController
  /// Returns null if controller is not available
  static QuizController? getQuizController() {
    try {
      return Get.find<QuizController>();
    } catch (e) {
      print('⚠️ QuizController not available: $e');
      return null;
    }
  }

  /// Helper method to ensure QuizController is initialized
  /// This prevents "QuizController not found" errors
  static QuizController ensureQuizController() {
    try {
      return Get.find<QuizController>();
    } catch (e) {
      print('🔄 QuizController not found, initializing...');
      // Initialize the controller if not found
      Get.put<QuizController>(QuizController());
      return Get.find<QuizController>();
    }
  }

  /// Helper method to get lesson quiz details from course details
  /// This is the ONLY correct way to get lesson quiz details
  static Future<Quiz?> getLessonQuizDetails(int courseId, int lessonId) async {
    try {
      print('🔍 [LessonQuiz] Getting course details for courseId: $courseId');
      var courseDetails = await getCourseDetails(courseId);
      if (courseDetails == null) {
        print(
            '❌ [LessonQuiz] Failed to get course details for courseId: $courseId');
        return null;
      }
      print(
          '✅ [LessonQuiz] Course details loaded. Looking for lessonId: $lessonId');
      final lesson =
          courseDetails.lessons?.firstWhereOrNull((l) => l.id == lessonId);
      if (lesson == null) {
        print('❌ [LessonQuiz] Lesson $lessonId not found in course $courseId');
        return null;
      }
      print('✅ [LessonQuiz] Found lesson. quiz_id: ${lesson.quizId}');
      if (lesson.quizId == null) {
        print('❌ [LessonQuiz] No quiz_id for lesson $lessonId');
        return null;
      }
      // Get token
      String token = "";
      try {
        final dashboardController = Get.find<DashboardController>();
        token = await dashboardController.userToken
                .read(dashboardController.tokenKey) ??
            "";
      } catch (e) {
        print(
            '❌ [LessonQuiz] Could not get token from dashboard controller: $e');
      }
      if (token.isEmpty || token == 'null') {
        print('❌ [LessonQuiz] No valid token found. Please log in again.');
        throw Exception('No valid token found. Please log in again.');
      }
      // Call lesson quiz details endpoint
      print(
          '🔍 [LessonQuiz] Fetching quiz details for quiz_id: ${lesson.quizId}');
      final quiz =
          await getLessonQuizDetailsByQuizId(lesson.quizId!, token: token);
      if (quiz == null) {
        print(
            '❌ [LessonQuiz] Failed to get quiz details for quiz_id: ${lesson.quizId}');
        return null;
      }
      print('✅ [LessonQuiz] Quiz details loaded for quiz_id: ${lesson.quizId}');
      return quiz;
    } catch (e, stackTrace) {
      debugPrint('[LessonQuiz] Error: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// API: Get Lesson Quiz Details by quiz_id (Website Exact Implementation)
  /// GET /api/get-lesson-quiz-details/{quiz_id}
  /// Headers: Authorization: Bearer {token}, Accept: application/json
  /// Returns the Quiz object for the lesson quiz
  static Future<Quiz?> getLessonQuizDetailsByQuizId(int quizId,
      {required String token}) async {
    try {
      // Validate token before making request
      if (token.isEmpty) {
        print('❌ Token is empty for lesson quiz details request');
        return null;
      }

      // Use exact URL format as Postman example
      Uri url = Uri.parse(
          'https://elmobd3-mohamed-samy.com/api/get-lesson-quiz-details/$quizId');
      print('🔍 Getting lesson quiz details by quiz_id from: $url');

      // Use headers as per website (Bearer token, Accept, ApiKey)
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
      };
      print('🔑 Using headers: $headers');

      var response = await http.get(url, headers: headers);
      print('🔍 Lesson quiz details response status: ${response.statusCode}');
      print('🔍 Lesson quiz details response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        print('🔍 Lesson quiz details JSON: $jsonString');
        print('🔍 Success field: ${jsonString['success']}');
        print('🔍 Data exists: ${jsonString['data'] != null}');
        print('🔍 Quiz exists: ${jsonString['data']?['quiz'] != null}');

        if (jsonString['success'] == true &&
            jsonString['data'] != null &&
            jsonString['data']['quiz'] != null) {
          var quiz = Quiz.fromJson(jsonString['data']['quiz']);
          print('✅ Quiz loaded successfully:');
          print('✅ - Quiz ID: ${quiz.id}');
          print('✅ - Quiz Title: ${quiz.title}');
          print('✅ - Questions count: ${quiz.assign?.length ?? 0}');
          return quiz;
        } else {
          print('❌ No quiz data found in lesson quiz details response');
          return null;
        }
      } else if (response.statusCode == 403) {
        print('❌ 403 Unauthorized - Token might be invalid or expired');
        print('🔍 Response: ${response.body}');
        return null;
      } else {
        debugPrint(
            'Get lesson quiz details by quiz_id failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getLessonQuizDetailsByQuizId: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }
}
