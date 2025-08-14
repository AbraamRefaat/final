import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Coupon.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

class CouponService {
  GetStorage userToken = GetStorage();
  String tokenKey = "token";

  // Apply coupon using the correct API endpoint (matching website implementation)
  Future<Map<String, dynamic>> applyCoupon(
      String couponCode, double totalAmount) async {
    try {
      String? token = userToken.read(tokenKey);
      if (token == null) {
        return {
          'success': false,
          'message': 'Please login first',
        };
      }

      if (couponCode.isEmpty) {
        return {
          'success': false,
          'message': 'Please enter a coupon code',
        };
      }

      print('🎫 Applying coupon: $couponCode');
      print('💰 Total amount: $totalAmount');

      // Use the working API endpoint for applying coupons
      Uri url = Uri.parse('$baseUrl/apply-coupon');

      // Prepare request data matching the working API format
      Map<String, dynamic> requestData = {
        'code': couponCode,
        'total': totalAmount.toString(),
        'type': '0', // Required parameter for API
      };

      print('📤 Sending request to: $url');
      print('📄 Request data: ${jsonEncode(requestData)}');

      // Create headers matching the API documentation
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      // Try POST request first (more common for API endpoints)
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      // If POST fails, try GET with query parameters (as per documentation)
      if (response.statusCode != 200) {
        print('📝 POST failed, trying GET with query parameters...');
        response = await http.get(
          url.replace(queryParameters: requestData),
          headers: headers,
        );
      }

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          return {
            'success': true,
            'message': jsonData['message'] ?? 'Coupon applied successfully',
            'total': jsonData['total'] ?? totalAmount.toString(),
            'discount': jsonData['discount'] ?? '0',
            'tax': jsonData['tax'] ?? '0',
            'final_amount': jsonData['final_amount'] ?? totalAmount.toString(),
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Coupon application failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Coupon application error: $e');
      return {
        'success': false,
        'message': 'Error applying coupon: $e',
      };
    }
  }

  // Verify coupon format (basic client-side validation)
  bool isValidCouponFormat(String couponCode) {
    if (couponCode.isEmpty) return false;
    // Basic validation - at least 3 characters, alphanumeric
    return couponCode.length >= 3 &&
        RegExp(r'^[a-zA-Z0-9]+$').hasMatch(couponCode);
  }

  // Remove coupon - simplified approach
  Future<Map<String, dynamic>> removeCoupon(double totalAmount) async {
    try {
      print('🗑️ Removing coupon locally');

      // For now, just return success to update UI
      // The actual coupon removal will happen when the order is completed
      return {
        'success': true,
        'message': 'Coupon removed successfully',
        'total': totalAmount.toString(),
        'discount': '0',
        'final_amount': totalAmount.toString(),
      };
    } catch (e) {
      print('❌ Coupon removal error: $e');
      return {
        'success': false,
        'message': 'Error removing coupon: $e',
      };
    }
  }

  // Get localized error message based on error type
  String getLocalizedErrorMessage(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'invalid':
        return 'Invalid coupon code';
      case 'expired':
        return 'This coupon has expired';
      case 'used':
        return 'You have already used this coupon';
      case 'minimum':
        return 'Minimum purchase amount not met';
      case 'course':
        return 'This coupon is not valid for this course';
      case 'user':
        return 'This coupon is not for you';
      default:
        return errorType;
    }
  }

  // Determine error type from message
  String getCouponErrorType(String message) {
    String lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('not found')) {
      return 'invalid';
    } else if (lowerMessage.contains('expired')) {
      return 'expired';
    } else if (lowerMessage.contains('used') ||
        lowerMessage.contains('already')) {
      return 'used';
    } else if (lowerMessage.contains('minimum')) {
      return 'minimum';
    } else if (lowerMessage.contains('course')) {
      return 'course';
    } else if (lowerMessage.contains('not for you')) {
      return 'user';
    }

    return message; // Return original message if no pattern matches
  }
}
