import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Cart/ModelCartList.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

class CartService {
  GetStorage userToken = GetStorage();
  String tokenKey = "token";

  // Add course to cart
  Future<bool> addToCart(int courseId) async {
    try {
      String? token = userToken.read(tokenKey);
      if (token == null) {
        print('❌ No token found for add-to-cart');
        CustomSnackBar().snackBarError('Please login first');
        return false;
      }

      // Use the new API endpoint format from user's request
      Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/api/add-to-cart/$courseId');
      print('📤 Adding course $courseId to cart: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      // Create headers with Bearer token and ApiKey as specified
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      var response = await http.get(url, headers: headers);

      print('📥 Add-to-cart response status: ${response.statusCode}');
      print('📥 Add-to-cart response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          print('✅ Successfully added course $courseId to cart');
          CustomSnackBar().snackBarSuccess('Course added to cart');
          return true;
        } else {
          String message = jsonData['message'] ?? '';
          print('❌ Add-to-cart API returned success=false: $message');

          // Handle "already in cart" as success (course is in cart = goal achieved)
          if (message.toLowerCase().contains('already added') ||
              message.toLowerCase().contains('already in cart')) {
            print('✅ Course $courseId already in cart - treating as success');
            CustomSnackBar().snackBarSuccess('Course already in cart');
            return true;
          }

          CustomSnackBar().snackBarError(message);
          return false;
        }
      } else {
        print('❌ Add-to-cart HTTP error: ${response.statusCode}');
        print('❌ Add-to-cart error response: ${response.body}');
        CustomSnackBar().snackBarError('Failed to add to cart');
        return false;
      }
    } catch (e) {
      print('❌ Add-to-cart exception: $e');
      CustomSnackBar().snackBarError('Error adding to cart: $e');
      return false;
    }
  }

  // Remove course from cart
  Future<bool> removeFromCart(int courseId) async {
    try {
      String? token = userToken.read(tokenKey);
      if (token == null) {
        CustomSnackBar().snackBarError('Please login first');
        return false;
      }

      // Use the new API endpoint format from user's request
      Uri url =
          Uri.parse('https://elmobd3-mohamed-samy.com/api/remove-to-cart/$courseId');

      // Create headers with Bearer token and ApiKey as specified
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      var response = await http.get(url, headers: headers);
      print('Remove from cart response: ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'نجاح' || jsonData['success'] == true) {
          CustomSnackBar().snackBarSuccess('Removed from cart');
          return true;
        } else {
          CustomSnackBar().snackBarError(
              jsonData['message'] ?? 'Failed to remove from cart');
          return false;
        }
      } else {
        CustomSnackBar().snackBarError('Failed to remove from cart');
        return false;
      }
    } catch (e) {
      CustomSnackBar().snackBarError('Error removing from cart: $e');
      return false;
    }
  }

  // Get cart list
  Future<List<CartList>> getCartList() async {
    try {
      String? token = userToken.read(tokenKey);
      if (token == null) {
        print('❌ No token found for get-cart-list');
        throw Exception('Please login first');
      }

      // Use the new API endpoint format from user's request
      Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/api/cart-list');
      print('📤 Getting cart list: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      // Create headers with Bearer token and ApiKey as specified
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      var response = await http.get(url, headers: headers);

      print('📥 Get-cart-list response status: ${response.statusCode}');
      print('📥 Get-cart-list response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<CartList> cartList = [];
          List<dynamic> data = jsonData['data'];
          print('📊 Cart data from API: ${data.length} items');

          for (var item in data) {
            print('📦 Processing cart item: ${item.toString()}');
            cartList.add(await CartList.createWithCourseDetails(item));
          }

          print('✅ Successfully loaded ${cartList.length} cart items');
          return cartList;
        } else {
          print('⚠️ Cart API returned success=false or null data');
          print('⚠️ Response data: ${jsonData.toString()}');
          return [];
        }
      } else {
        print('❌ Get-cart-list HTTP error: ${response.statusCode}');
        print('❌ Get-cart-list error response: ${response.body}');
        throw Exception('Failed to get cart list');
      }
    } catch (e) {
      print('❌ Get-cart-list exception: $e');
      throw Exception('Error getting cart list: $e');
    }
  }

  // Make order with coupon - Including required billing address fields
  Future<Map<String, dynamic>> makeOrder({String? couponCode}) async {
    try {
      String? token = userToken.read(tokenKey);
      if (token == null) {
        throw Exception('Please login first');
      }

      print('🔄 Making order with coupon: $couponCode');
      print('🔑 Token: $token');

      // Use the API endpoint
      Uri url = Uri.parse('https://elmobd3-mohamed-samy.com/api/make-order');

      // SOLUTION: Handle existing billing address properly
      // Get user's existing billing addresses first
      String? existingBillingId;
      try {
        Uri billingUrl = Uri.parse('$baseUrl/my-billing-address');
        var billingResponse =
            await http.get(billingUrl, headers: header(token: token));

        if (billingResponse.statusCode == 200) {
          var billingData = jsonDecode(billingResponse.body);
          if (billingData['success'] == true &&
              billingData['data'] != null &&
              billingData['data'].isNotEmpty) {
            // Use the first/latest billing address
            existingBillingId = billingData['data'][0]['id'].toString();
            print('📍 Found existing billing ID: $existingBillingId');
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch billing addresses: $e');
      }

      // Prepare request body
      Map<String, dynamic> body = {
        'coupon_code': couponCode ?? '',
      };

      // If we have existing billing, use it
      if (existingBillingId != null) {
        body['billing_address'] = 'previous';
        body['old_billing'] = existingBillingId;
        print('📋 Using existing billing address: $existingBillingId');
      } else {
        // No existing billing - let API auto-generate
        print('📋 No existing billing - letting API auto-generate');
      }

      print('📝 Smart billing request - handling existing vs new billing');
      print('📤 Sending make-order request to: $url');
      print('📄 Request body: ${jsonEncode(body)}');

      // Create headers with Bearer token and ApiKey as specified in Postman
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ApiKey':
            '1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf',
      };

      print('📋 Request headers: $headers');

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Make-order response status: ${response.statusCode}');
      print('📥 Make-order response body: ${response.body}');

      // If still failing due to billing, try clearing billing and let API auto-generate new one
      if (response.statusCode == 400 &&
          response.body.contains('Invalid billing address')) {
        print(
            '🔄 Billing issue detected, trying to force new billing creation...');

        // Try with empty body to force new billing auto-generation
        Map<String, dynamic> fallbackBody = {
          'coupon_code': couponCode ?? '',
        };

        print(
            '📤 Retrying with fallback approach: ${jsonEncode(fallbackBody)}');

        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(fallbackBody),
        );

        print('📥 Fallback response status: ${response.statusCode}');
        print('📥 Fallback response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          print('✅ Order successful');
          return {
            'success': true,
            'message': jsonData['message'] ?? 'Order completed successfully',
            'tracking': jsonData['tracking'],
            'order_id': jsonData['order_id'],
            'data': jsonData['data'],
            'discount_amount': jsonData['discount_amount'],
            'final_amount': jsonData['final_amount'],
          };
        } else {
          String errorMessage = jsonData['message'] ?? 'Order failed';
          print('❌ Order failed: $errorMessage');

          return {
            'success': false,
            'message': errorMessage,
            'error_type': 'api_error',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        var errorData = jsonDecode(response.body);

        return {
          'success': false,
          'message': errorData['message'] ??
              'Order failed with HTTP ${response.statusCode}',
          'error_type': 'http_error',
        };
      }
    } catch (e) {
      print('❌ Exception during make-order: $e');
      return {
        'success': false,
        'message': 'Error making order: $e',
        'error_type': 'exception',
      };
    }
  }

  // Calculate total price from cart
  Future<double> calculateTotalPrice() async {
    try {
      List<CartList> cartItems = await getCartList();
      double total = 0;
      for (var item in cartItems) {
        total += item.price ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Get cart count
  Future<int> getCartCount() async {
    try {
      List<CartList> cartItems = await getCartList();
      return cartItems.length;
    } catch (e) {
      return 0;
    }
  }

  // Clear cart (if needed)
  Future<bool> clearCart() async {
    try {
      List<CartList> cartItems = await getCartList();
      for (var item in cartItems) {
        await removeFromCart(item.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
