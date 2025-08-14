// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// Project imports:

import 'package:untitled2/Model/Quiz/MyQuizResultsModel.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Model/User/User.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';
import 'package:untitled2/NewControllerAndModels/models/my_class_model.dart';
import 'package:untitled2/NewControllerAndModels/models/my_course_model.dart';
import 'package:untitled2/NewControllerAndModels/models/my_quiz_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Cart/ModelCartList.dart';
import 'package:untitled2/Model/ModelTopCategory.dart';
import 'package:untitled2/Model/Cart/PaymentListModel.dart';
import 'package:untitled2/Model/Quiz/QuestionResultModel.dart';
import 'package:untitled2/Model/Quiz/QuizStartModel.dart';
import 'package:untitled2/Model/CourseReport.dart';

class RemoteServices {
  // static var client = http.Client();

  static GetStorage userToken = GetStorage();

// save user token to memory
  String tokenKey = "token";

  Future<void> saveToken(String msg) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(tokenKey, msg);
  }

  static String getJoinMeetingUrlApp({mid, passcode}) {
    return 'zoomus://zoom.us/join?confno=$mid&pwd=$passcode'; // android
  }

  static String getJoinMeetingUrlWeb({mid, passcode}) {
    // return 'https://zoom.us/wc/$mid/join?prefer=1';
    return "https://zoom.us/wc/$mid/join?pwd=$passcode";
  }

// network call for Top category
  static Future<List<TopCategory>?> fetchTopCat() async {
    try {
      Uri topCatUrl = Uri.parse(baseUrl + '/categories');

      var response = await http.get(topCatUrl, headers: header());

      List<TopCategory> finalCategories = [];

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']);
          var apiCategories = topCategoryFromJson(courseData);

          if (apiCategories != null) {
            finalCategories.addAll(apiCategories);
          }
        }
      }

      // Add secondary categories as fallback (with default course count)
      List<String> requiredCategories = [
        'Secondary One',
        'Secondary Two',
        'Secondary Three'
      ];

      for (int i = 0; i < requiredCategories.length; i++) {
        String categoryName = requiredCategories[i];

        // Check if this category already exists in API response
        bool categoryExists = finalCategories.any((cat) =>
            cat.name?.toLowerCase() == categoryName.toLowerCase() ||
            cat.name?.toLowerCase().contains(categoryName.toLowerCase()) ==
                true);

        // If category doesn't exist in API, add it as a default category
        if (!categoryExists) {
          finalCategories.add(TopCategory(
            id: 1000 + i, // Use high IDs to avoid conflicts with API IDs
            name: categoryName,
            courseCount:
                0, // Default to 0 for now, will be updated later if needed
          ));
        }
      }

      return finalCategories;
    } catch (e) {
      // Return at least the secondary categories as fallback
      return [
        TopCategory(id: 1000, name: 'Secondary One', courseCount: 0),
        TopCategory(id: 1001, name: 'Secondary Two', courseCount: 0),
        TopCategory(id: 1002, name: 'Secondary Three', courseCount: 0),
      ];
    }
  }

  // Simplified helper method for future use
  static Future<int> _getCourseCountForCategory(String categoryName) async {
    try {
      Uri coursesUrl = Uri.parse(baseUrl + '/get-all-courses');
      var response = await http.get(coursesUrl, headers: header());

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courses = jsonString['data'] as List;

          // Filter courses that might belong to this category
          int count = courses.where((course) {
            String courseTitle =
                (course['title'] ?? '').toString().toLowerCase();
            String categoryLower = categoryName.toLowerCase();

            // Check if course title contains category keywords
            return courseTitle.contains('secondary') ||
                courseTitle.contains(categoryLower) ||
                courseTitle.contains('ثانوية'); // Arabic for secondary
          }).length;

          return count;
        }
      }
    } catch (e) {
      print('Error getting course count for $categoryName: $e');
    }

    return 0;
  }

// network call for Popular course list
  static Future<List<Course>?> fetchpopularCat() async {
    try {
      print('🔍 Starting fetchpopularCat...');
      Uri topCatUrl = Uri.parse(baseUrl + '/get-popular-courses');
      print('📍 Popular Courses URL: $topCatUrl');

      var response = await http.get(topCatUrl, headers: header());
      print('📡 Popular Courses API Response Status: ${response.statusCode}');
      print('📡 Popular Courses API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']);
          var courses = List<Course>.from(
              json.decode(courseData).map((x) => Course.fromJson(x))).toList();
          print('✅ Popular Courses loaded: ${courses.length}');
          return courses;
        } else {
          print('❌ Popular Courses API success=false or data=null');
          return [];
        }
      } else {
        print(
            '❌ Popular Courses API failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error in fetchpopularCat: $e');
      return null;
    }
  }

  // network call for All course list
  static Future<List<Course>?> fetchallCourse() async {
    try {
      print('🔍 Starting fetchallCourse...');
      Uri topCatUrl = Uri.parse(baseUrl + '/get-all-courses');
      print('📍 All Courses URL: $topCatUrl');

      var response = await http.get(topCatUrl, headers: header());
      print('📡 All Courses API Response Status: ${response.statusCode}');
      print('📡 All Courses API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);

        if (jsonString['success'] == true && jsonString['data'] != null) {
          var courseData = jsonEncode(jsonString['data']);
          var courses = List<Course>.from(
              json.decode(courseData).map((x) => Course.fromJson(x))).toList();
          print('✅ All Courses loaded: ${courses.length}');
          return courses;
        } else {
          print('❌ All Courses API success=false or data=null');
          return [];
        }
      } else {
        print('❌ All Courses API failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error in fetchallCourse: $e');
      return null;
    }
  }

  // TODO: No filter-course endpoint in new API
  // static Future<List<Course>?> filterCourse(
  //     category, level, language, price) async {
  //   Uri topCatUrl = Uri.parse(baseUrl +
  //       '/filter-course?category=$category&level=$level&language=$language&price=$price');
  //   var response = await http.get(topCatUrl, headers: header());
  //   if (response.statusCode == 200) {
  //     var jsonString = jsonDecode(response.body);
  //     var courseData = jsonEncode(jsonString['data']);
  //     return List<Course>.from(
  //         json.decode(courseData).map((x) => Course.fromJson(x))).toList();
  //   } else {
  //     //show error message
  //     return null;
  //   }
  // }

  // network call for All course list (enrolled courses/classes)
  static Future<List<MyCourseModel>?> fetchMyCourse(String token) async {
    Uri myCourseUrl = Uri.parse('https://elmobd3-mohamed-samy.com/api/my-courses');

    // Create headers with Bearer token and ApiKey as specified in user's API collection
    Map<String, String> headers = {
      'Accept': 'application/json',
      'ApiKey':
          '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      'Authorization': 'Bearer $token',
    };

    print('📤 Fetching enrolled courses: $myCourseUrl');
    print('🔑 Using token: ${token.substring(0, 20)}...');
    print('🔗 FULL BEARER TOKEN: $token');
    print('🔗 Copy this token: Bearer $token');

    var response = await http.get(myCourseUrl, headers: headers);

    print('📥 My-courses response status: ${response.statusCode}');
    print('📥 My-courses response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      print('🔍 Parsed JSON structure: $jsonString');

      // Check if response has the expected structure
      if (jsonString['success'] == true && jsonString['data'] != null) {
        var courses = jsonString['data'] as List;
        print('✅ Successfully loaded ${courses.length} enrolled courses');
        print(
            '📋 First course data: ${courses.isNotEmpty ? courses[0] : 'No courses'}');

        // Try to parse each course
        List<MyCourseModel> parsedCourses = [];
        for (var course in courses) {
          try {
            var parsedCourse = MyCourseModel.fromJson(course);
            parsedCourses.add(parsedCourse);
            print('✅ Successfully parsed course: ${parsedCourse.title}');
          } catch (e) {
            print('❌ Failed to parse course: $course');
            print('❌ Error: $e');
          }
        }
        return parsedCourses;
      } else {
        print('⚠️ API returned success=false or null data');
        print('⚠️ Response structure: $jsonString');
        return [];
      }
    } else {
      print('❌ Failed to fetch enrolled courses: ${response.statusCode}');
      return null;
    }
  }

// user login
  static Future<Map<String, dynamic>?> login(
      String phone, String password) async {
    // Changed from email to phone
    try {
      Uri loginUrl =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/login'); // Updated endpoint
      Map data = {
        "phone": phone.toString(), // Changed from email to phone
        "password": password.toString(),
      };
      //encode Map to JSON
      var body = json.encode(data);
      var response = await http.post(loginUrl,
          headers: {
            'Accept': 'application/json',
            'ApiKey':
                '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
            'Content-Type': 'application/json',
          },
          body: body); // Updated headers

      if (response.body.isEmpty) {
        Get.snackbar(
          "Login Failed",
          "Empty response from server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return null;
      }

      var jsonString = jsonDecode(response.body);
      print('Login Response: $jsonString');

      if (response.statusCode == 200) {
        return jsonString;
      } else {
        var errorMessage = "Login Failed";
        if (jsonString is Map<String, dynamic>) {
          errorMessage = jsonString['message']?.toString() ?? errorMessage;
        }

        Get.snackbar(
          errorMessage,
          "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        "Login Error",
        "Network error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 5,
      );
      return null;
    }
  }

  static Future register(name, phone, password, confirmPassword,
      studentWhatsAppNumber, guardianNumber, studyType, studentCode) async {
    try {
      Uri signUpUrl = Uri.parse(baseUrl + '/register');
      
      Map<String, String> data = {
        "name": name.toString(),
        "phone": phone.toString(),
        "password": password.toString(),
        "password_confirmation": confirmPassword.toString(),
        "study_type": studyType.toString(),
        "student_whatsapp": studentWhatsAppNumber.toString(),
        "parent_phone": guardianNumber.toString(),
      };

      // Add student_code only if study_type is offline and code is provided
      if (studyType.toString() == "offline" && studentCode.toString().isNotEmpty) {
        data["student_code"] = studentCode.toString();
      }

      // Use form-encoded format like the web version
      var body = data.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      
      // Test API connectivity first
      print('🌐 Testing API connectivity...');
      try {
        var testResponse = await http.get(Uri.parse(baseUrl + '/categories'), headers: header()).timeout(Duration(seconds: 10));
        print('✅ API connectivity test: ${testResponse.statusCode}');
      } catch (e) {
        print('❌ API connectivity test failed: $e');
      }

      // Use form headers instead of JSON headers
      Map<String, String> formHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'ApiKey': backendApiKey,
      };

      print('🚀 Registration request details:');
      print('📍 URL: $signUpUrl');
      print('📦 Body: $body');
      print('📋 Headers: $formHeaders');
      print('📱 Platform: Mobile App (using web endpoint format)');
      
      var response = await http.post(signUpUrl, headers: formHeaders, body: body);

      print('Registration response status: ${response.statusCode}');
      print('Registration response headers: ${response.headers}');
      print('Registration response body: ${response.body}');

      // Handle successful registration (201 status)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle empty or invalid response body
        if (response.body.isEmpty || response.body == '[]') {
          print('✅ Registration successful (empty response body)');
          // Return success response even with empty body
          return {
            'success': true,
            'message': 'Registration successful',
            'data': null
          };
        }

        try {
          dynamic jsonResponse = jsonDecode(response.body);
          print('Registration Response: $jsonResponse');
          print('Response type: ${jsonResponse.runtimeType}');
          
          // Handle different response types safely
          if (jsonResponse is Map<String, dynamic>) {
            // Standard JSON object response
            if (jsonResponse['success'] == true || jsonResponse['data'] != null) {
              return jsonResponse;
            } else {
              var errorMessage = jsonResponse['message']?.toString() ?? 'Registration failed';
              Get.snackbar(
                "Registration Failed",
                errorMessage,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                borderRadius: 5,
              );
              return null;
            }
          } else if (jsonResponse is List) {
            // Handle array response as success (like current server behavior)
            print('✅ Registration successful (array response)');
            return {
              'success': true,
              'message': 'Registration successful',
              'data': {'response': jsonResponse}
            };
          } else {
            // Handle any other type as success since status is 201
            print('✅ Registration successful (unknown response type: ${jsonResponse.runtimeType})');
            return {
              'success': true,
              'message': 'Registration successful',
              'data': {'response': jsonResponse.toString()}
            };
          }
        } catch (e) {
          print('⚠️ JSON parsing error, but registration status is success: $e');
          print('⚠️ Raw response body: "${response.body}"');
          // If we can't parse JSON but status is 201, treat as success
          return {
            'success': true,
            'message': 'Registration successful',
            'data': null
          };
        }
      } else {
        // Handle different error status codes
        var errorMessage = "Registration failed";
        try {
          dynamic jsonResponse = jsonDecode(response.body);
          if (jsonResponse is Map<String, dynamic>) {
            errorMessage = jsonResponse['message']?.toString() ?? errorMessage;
          }
        } catch (e) {
          print('⚠️ Error parsing error response: $e');
        }

        // Log detailed error information
        print('❌ Registration failed with status: ${response.statusCode}');
        print('❌ Error message: $errorMessage');
        print('❌ Full response: ${response.body}');

        // Show specific error message based on the server response
        String displayMessage = errorMessage;
        if (errorMessage.contains('userRepository')) {
          displayMessage = 'Server configuration error. Please contact support.';
        }

        Get.snackbar(
          "Registration Failed",
          displayMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
          duration: Duration(seconds: 5),
        );
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Registration error: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        "Registration Error",
        "Network error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 5,
      );
      return null;
    }
  }

  //get single course data

  static Future<CourseMain?> getCourseDetails(int id) async {
    Uri topCatUrl = Uri.parse(baseUrl + '/get-course-details/$id');
    print('🔍 getCourseDetails API call: $topCatUrl');
    var response = await http.get(topCatUrl, headers: header());
    print('📥 getCourseDetails response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      print(
          '📊 Raw API response for course $id: ${jsonString['data']?['id']} - ${jsonString['data']?['title']}');
      var courseData = jsonEncode(jsonString['data']);
      var courseDetails = CourseMain.fromJson(json.decode(courseData));
      print(
          '✅ Parsed course details: ID=${courseDetails.id}, Title=${courseDetails.title}');
      return courseDetails;
    } else {
      print('❌ getCourseDetails failed with status: ${response.statusCode}');
      return null;
    }
  }

  //get My course details (enrolled class details)
  static Future<CourseMain?> getMyCourseDetails(int id) async {
    Uri topCatUrl =
        Uri.parse('https://elmobd3-mohamed-samy.com/api/get-course-details/$id');

    // Create headers with ApiKey as specified in user's API collection
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ApiKey':
          '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
    };

    print('📤 Fetching course details: $topCatUrl');

    var response = await http.get(topCatUrl, headers: headers);

    print('📥 Course details response status: ${response.statusCode}');
    print('📥 Course details response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      if (jsonString['success'] == true && jsonString['data'] != null) {
        var courseData = jsonEncode(jsonString['data']);
        print('✅ Successfully loaded course details for ID: $id');
        return CourseMain.fromJson(json.decode(courseData));
      } else {
        print('⚠️ Course details API returned success=false or null data');
        return null;
      }
    } else {
      print('❌ Failed to fetch course details: ${response.statusCode}');
      return null;
    }
  }

  // add to cart
  static Future<CourseMain?> addToCard(String token, String courseID) async {
    Uri cartList = Uri.parse(baseUrl + '/add-to-cart/' + courseID);
    var response = await http.get(cartList, headers: header(token: token));
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return CourseMain.fromJson(json.decode(courseData));
    } else {
      //show error message
      return null;
    }
  }

  // remove from cart
  static Future<CourseMain?> removeFromCard(
      String token, String courseID) async {
    Uri cartList = Uri.parse(baseUrl + '/remove-to-cart/' + courseID);
    var response = await http.get(cartList, headers: header(token: token));
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return CourseMain.fromJson(json.decode(courseData));
    } else {
      //show error message
      return null;
    }
  }

  // view card list

  static Future<List<CartList>?> getCartList(String token) async {
    Uri cartListUri = Uri.parse('$baseUrl/cart-list');
    var response = await http.get(cartListUri, headers: header(token: token));

    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var data = jsonString['data'];

      if (data != null && data is List) {
        List<CartList> cartList = [];
        for (var item in data) {
          cartList.add(await CartList.createWithCourseDetails(item));
        }
        return cartList;
      } else {
        return [];
      }
    } else {
      // Show error message or handle error
      return null;
    }
  }

  //my Course List
  static Future<CartList?> getMyCourseList(String token) async {
    Uri cartList = Uri.parse(baseUrl + '/my-courses');
    var response = await http.get(cartList, headers: header(token: token));
    if (response.statusCode == 200) {
      return null;
    } else {
      //show error message
      return null;
    }
  }

  //payment methode list
  static Future<List<PaymentListModel>?> getPaymentList() async {
    Uri cartList = Uri.parse(baseUrl + '/payment-gateways');
    var response = await http.get(cartList, headers: header());
    print(response.body);
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return paymentListModelFromJson(courseData);
    } else {
      //show error message
      return null;
    }
  }

  // user profile data
  static Future<User?> getProfile(String token) async {
    Uri profileUrl = Uri.parse(baseUrl + '/user');
    var response = await http.get(profileUrl, headers: header(token: token));
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var userData = jsonEncode(jsonString['data']);
      return User.fromJson(json.decode(userData));
    } else {
      return null;
    }
  }

  // remove from cart
  static Future<String?> remoteCartRemove(String token, int id) async {
    Uri userData = Uri.parse(baseUrl + '/remove-to-cart/' + id.toString());

    var response = await http.get(
      userData,
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var message = jsonEncode(jsonString['message']);
      return message;
    } else {
      //show error message
      return null;
    }
  }

  static Future<dynamic> couponApply(
      {String? token, String? code, dynamic totalAmount}) async {
    Map<String, dynamic> bodyData = {
      'code': code.toString(),
      'total': totalAmount.toString(),
    };
    Uri userData = Uri.parse(baseUrl + '/apply-coupon');
    var body = json.encode(bodyData);
    var response = await http.post(
      userData,
      headers: header(token: token),
      body: body,
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      return jsonString;
    } else {
      //show error message
      return null;
    }
  }

  static Future<List<Course>?> fetchAllClass() async {
    Uri allClassUrl = Uri.parse(baseUrl + '/get-all-classes');
    var response = await http.get(allClassUrl, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return List<Course>.from(
          json.decode(courseData).map((x) => Course.fromJson(x))).toList();
    } else {
      //show error message
      return null;
    }
  }

  static Future<List<Course>?> fetchPopularClasses() async {
    Uri allCourseUrl = Uri.parse(baseUrl + '/get-popular-classes');
    var response = await http.get(allCourseUrl, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return List<Course>.from(
          json.decode(courseData).map((x) => Course.fromJson(x))).toList();
    } else {
      //show error message
      return null;
    }
  }

  static Future<CourseMain?> getClassDetails(int id) async {
    Uri topCatUrl = Uri.parse(baseUrl + '/get-class-details/$id');
    var response = await http.get(topCatUrl, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return CourseMain.fromJson(json.decode(courseData));
    } else {
      //show error message
      return null;
    }
  }

  static Future<List<MyClassModel>?> fetchAllMyClass(String token) async {
    Uri allCourseUrl = Uri.parse(baseUrl + '/my-classes');
    var response = await http.get(
      allCourseUrl,
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return List<MyClassModel>.from(
              json.decode(courseData).map((x) => MyClassModel.fromJson(x)))
          .toList();
    } else {
      //show error message
      return null;
    }
  }

  static Future<List<Course>?> fetchAllQuizzes() async {
    Uri url = Uri.parse(baseUrl + '/get-all-quizzes');

    try {
      var response = await http.get(url, headers: header());
      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var courseData = jsonEncode(jsonString['data']);
        return List<Course>.from(
            json.decode(courseData).map((x) => Course.fromJson(x))).toList();
      } else {
        //show error message
        return null;
      }
    } catch (e, t) {
      debugPrint('$e');
      debugPrint('$t');
    }
    return null;
  }

  static Future<List<MyQuizModel>?> fetchAllMyQuizzes(String token) async {
    Uri url = Uri.parse(baseUrl + '/my-quizzes');
    var response = await http.get(
      url,
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return List<MyQuizModel>.from(
          json.decode(courseData).map((x) => MyQuizModel.fromJson(x))).toList();
    } else {
      //show error message
      return null;
    }
  }

  static Future<CourseMain?> getQuizDetails(int id) async {
    Uri url = Uri.parse(baseUrl + '/get-quiz-details/$id');
    var response = await http.get(url, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return CourseMain.fromJson(json.decode(courseData));
    } else {
      //show error message
      return null;
    }
  }

  // get lesson quiz details
  static Future<CourseMain?> getLessonQuizDetails(int id) async {
    Uri url = Uri.parse(baseUrl + '/get-lesson-quiz-details/$id');
    var response = await http.get(url, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString['data']);
      return CourseMain.fromJson(json.decode(courseData));
    } else {
      //show error message
      return null;
    }
  }

  static Future<MyQuizResultsModel?> getQuizResult(
      dynamic id, dynamic quizId, String token) async {
    Uri url = Uri.parse(baseUrl + '/quiz-result/$id/$quizId');
    var response = await http.post(
      url,
      headers: header(token: token),
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var courseData = jsonEncode(jsonString);
      return myQuizResultsModelFromJson(courseData);
    } else {
      //show error message
      return null;
    }
  }

  static Future<QuizStartModel?> startQuiz(
      {String? token, dynamic courseId, dynamic quizId}) async {
    // Use the exact same URL as website
    Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/quizTestStart');

    // Prepare request body EXACTLY as website does (form data, not JSON)
    Map<String, String> body = {
      'courseId': courseId.toString(),
      'quizId': quizId.toString(),
      'quizType': '2', // Default quiz type as per website
      'quiz_test_id': '',
      'focus_lost': '0',
    };

    // Use the exact same headers as website (but with Bearer token instead of CSRF)
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var response = await http.post(
      url,
      headers: headers,
      body: body, // Send as form data, not JSON
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var encodedString = jsonEncode(jsonString);
      return quizStartModelFromJson(encodedString);
    } else {
      //show error message
      return null;
    }
  }

  static Future<bool> singleAnswerSubmit({String? token, Map? data}) async {
    // Use the exact same URL as website
    Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/singleQuizSubmit');

    // Convert data to form data format (exactly as website)
    Map<String, String> formData = {};
    data?.forEach((key, value) {
      formData[key.toString()] = value.toString();
    });

    // Use the exact same headers as website (but with Bearer token instead of CSRF)
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var response = await http.post(
      url,
      headers: headers,
      body: formData, // Send as form data, not JSON
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<QuizResultModel?> questionResult(
      {String? token, int? quizResultId}) async {
    // Use the exact same URL as website
    Uri url =
        Uri.parse('https://elmobd3-mohamed-samy.com/quizResultPreviewApi/$quizResultId');

    // Use the exact same headers as website (but with Bearer token instead of CSRF)
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      var encodedString = jsonEncode(jsonString);
      return quizResultModelFromJson(encodedString);
    } else {
      return null;
    }
  }

  static Future<bool?> finalQuizSubmit(int quizStartId) async {
    // This method is used internally by the quiz system
    // For actual final quiz submission, use QuizService.submitFinalQuiz
    // Use the exact same URL as website
    Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/quizSubmit');

    // Create a simple body for the internal submission (form data, not JSON)
    Map<String, String> body = {
      'quiz_test_id': quizStartId.toString(),
      'focus_lost': '0',
    };

    // Get token from storage
    var token = userToken.read('token');

    // Use the exact same headers as website (but with Bearer token instead of CSRF)
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var response = await http.post(
      url,
      headers: headers,
      body: body, // Send as form data, not JSON
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  }

  /// NEW: Quiz History API
  /// POST /api/quiz-history/{quiz_id}
  /// Headers: Accept: application/json, ApiKey: {apiKey}, Authorization: Bearer {token}
  static Future<List<dynamic>?> getQuizHistory({
    required String token,
    required int quizId,
  }) async {
    try {
      Uri url = Uri.parse(baseUrl + '/quiz-history/$quizId');

      var response = await http.post(url, headers: header(token: token));

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        // Return the data array from the response
        return jsonString['data'] as List<dynamic>?;
      } else {
        debugPrint(
            'Get quiz history failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getQuizHistory: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  static Future<String> getPayTMTxnToken({
    required String userId,
    required String amount,
    required String currency,
    required String orderId,
  }) async {
    // TODO: This needs to be re-implemented with make-order and make-payment
    return '';
  }

  // get settings
  static Future fetchSetting() async {
    Uri settingsUrl = Uri.parse(baseUrl + '/settings');
    var response = await http.get(settingsUrl, headers: header());
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      return jsonString;
    } else {
      return null;
    }
  }

  // get course report (enrolled and finished courses count)
  static Future<CourseReport?> getCourseReport(String token) async {
    try {
      Uri courseReportUrl =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/course-report');

      // Create headers with Bearer token and ApiKey as specified in user's API collection
      Map<String, String> headers = {
        'Accept': 'application/json',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
        'Authorization': 'Bearer $token',
      };

      print('📤 Fetching course report: $courseReportUrl');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      var response = await http.get(courseReportUrl, headers: headers);

      print('📥 Course report response status: ${response.statusCode}');
      print('📥 Course report response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        print('🔍 Parsed JSON structure: $jsonString');

        // Check if response has the expected structure
        if (jsonString['success'] == true && jsonString['data'] != null) {
          print('✅ Successfully loaded course report');

          // Create CourseReport with the courses data
          var courseReport = CourseReport(
            success: jsonString['success'],
            message: jsonString['message'],
            data: CourseReportData.fromJson(jsonString['data']),
          );

          print(
              '📊 Total enrolled courses: ${courseReport.data?.enrolledCoursesCount ?? 0}');
          print(
              '📊 Finished courses: ${courseReport.data?.finishedCoursesCount ?? 0}');

          return courseReport;
        } else {
          print('⚠️ Course report API returned success=false or null data');
          print('⚠️ Response structure: $jsonString');
          return null;
        }
      } else {
        print('❌ Failed to fetch course report: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error in getCourseReport: $e');
      return null;
    }
  }

  // Test API connectivity and requirements
  static Future<void> testApiConnectivity() async {
    try {
      print('Testing API connectivity...');
      print('Base URL: $baseUrl');
      print('API Key: $backendApiKey');

      // Test 1: Try to access settings endpoint (usually doesn't require auth)
      Uri settingsUrl = Uri.parse(baseUrl + '/settings');
      print('Testing settings endpoint: $settingsUrl');

      var response = await http.get(settingsUrl, headers: header());
      print('Settings response status: ${response.statusCode}');
      print('Settings response body: ${response.body}');

      // Test 2: Test get-all-courses endpoint
      Uri coursesUrl = Uri.parse(baseUrl + '/get-all-courses');
      print('Testing courses endpoint: $coursesUrl');

      var coursesResponse = await http.get(coursesUrl, headers: header());
      print('Courses response status: ${coursesResponse.statusCode}');
      print(
          'Courses response body (first 200 chars): ${coursesResponse.body.length > 200 ? coursesResponse.body.substring(0, 200) + "..." : coursesResponse.body}');

      // Test 3: Test get-all-quizzes endpoint
      Uri quizzesUrl = Uri.parse(baseUrl + '/get-all-quizzes');
      print('Testing quizzes endpoint: $quizzesUrl');

      var quizzesResponse = await http.get(quizzesUrl, headers: header());
      print('Quizzes response status: ${quizzesResponse.statusCode}');
      print(
          'Quizzes response body (first 200 chars): ${quizzesResponse.body.length > 200 ? quizzesResponse.body.substring(0, 200) + "..." : quizzesResponse.body}');

      // Test 4: Test categories endpoint
      Uri categoriesUrl = Uri.parse(baseUrl + '/categories');
      print('Testing categories endpoint: $categoriesUrl');

      var categoriesResponse = await http.get(categoriesUrl, headers: header());
      print('Categories response status: ${categoriesResponse.statusCode}');
      print(
          'Categories response body (first 200 chars): ${categoriesResponse.body.length > 200 ? categoriesResponse.body.substring(0, 200) + "..." : categoriesResponse.body}');

      // Summary
      print('\n=== API TEST SUMMARY ===');
      print(
          'Settings: ${response.statusCode == 200 ? "✅ SUCCESS" : "❌ FAILED"}');
      print(
          'Courses: ${coursesResponse.statusCode == 200 ? "✅ SUCCESS" : "❌ FAILED"}');
      print(
          'Quizzes: ${quizzesResponse.statusCode == 200 ? "✅ SUCCESS" : "❌ FAILED"}');
      print(
          'Categories: ${categoriesResponse.statusCode == 200 ? "✅ SUCCESS" : "❌ FAILED"}');
      print('========================');
    } catch (e) {
      print('API connectivity test error: $e');
    }
  }

  // Test login functionality
  static Future<void> testLogin(String email, String password) async {
    try {
      print('Testing login with email: $email');
      var result = await login(email, password);
      if (result != null) {
        print('✅ Login successful!');
        print('Login result: $result');
      } else {
        print('❌ Login failed!');
      }
    } catch (e) {
      print('Login test error: $e');
    }
  }
}
