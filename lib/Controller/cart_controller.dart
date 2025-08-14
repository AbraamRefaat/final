import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Cart/ModelCartList.dart';
import 'package:untitled2/Service/cart_service.dart';
import 'package:untitled2/Service/coupon_service.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class CartController extends GetxController {
  final CartService cartService = CartService();
  final CouponService couponService = CouponService();
  final TextEditingController couponController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var isCouponVerifying = false.obs;
  var isProcessingOrder = false.obs;
  var cartItems = <CartList>[].obs;
  var cartCount = 0.obs;
  var totalAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var finalAmount = 0.0.obs;
  var appliedCoupon = ''.obs;
  var isCouponApplied = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  // Load cart items from service
  Future<void> loadCartItems() async {
    try {
      isLoading.value = true;
      List<CartList> items = await cartService.getCartList();
      cartItems.value = items;
      cartCount.value = items.length;
      calculateTotals();
    } catch (e) {
      print('❌ Cart loading error: $e');
      // Set empty cart instead of showing error
      cartItems.value = [];
      cartCount.value = 0;
      calculateTotals();
    } finally {
      isLoading.value = false;
    }
  }

  // Add course to cart
  Future<bool> addToCart(int courseId) async {
    try {
      bool success = await cartService.addToCart(courseId);
      if (success) {
        await loadCartItems(); // Refresh cart
        return true;
      }
      return false;
    } catch (e) {
      CustomSnackBar().snackBarError('Error adding to cart: $e');
      return false;
    }
  }

  // Remove course from cart
  Future<bool> removeFromCart(int courseId) async {
    try {
      bool success = await cartService.removeFromCart(courseId);
      if (success) {
        await loadCartItems(); // Refresh cart
        // Reset coupon if cart is empty
        if (cartItems.isEmpty) {
          resetCoupon();
        }
        return true;
      }
      return false;
    } catch (e) {
      CustomSnackBar().snackBarError('Error removing from cart: $e');
      return false;
    }
  }

  // Calculate totals
  void calculateTotals() {
    double total = 0;
    for (var item in cartItems) {
      total += item.price ?? 0;
    }
    totalAmount.value = total;

    // Recalculate final amount with discount
    if (isCouponApplied.value) {
      finalAmount.value = totalAmount.value - discountAmount.value;
    } else {
      finalAmount.value = totalAmount.value;
    }
  }

  // Apply coupon using correct API endpoint (separate from order creation)
  Future<void> applyCoupon() async {
    if (couponController.text.isEmpty) {
      CustomSnackBar().snackBarWarning('Please enter a coupon code');
      return;
    }

    if (cartItems.isEmpty) {
      CustomSnackBar().snackBarError(
          'Your cart is empty. Please add items to cart first before applying a coupon.');
      return;
    }

    try {
      isCouponVerifying.value = true;

      print('🛒 Cart has ${cartItems.length} items');
      print('💳 Applying coupon: ${couponController.text}');
      print('💰 Total amount: ${totalAmount.value}');

      // Use the correct coupon application API endpoint
      var result = await couponService.applyCoupon(
        couponController.text,
        totalAmount.value,
      );

      if (result['success'] == true) {
        // Coupon is valid - apply the discount
        appliedCoupon.value = couponController.text;
        isCouponApplied.value = true;

        // Extract discount information from API response
        discountAmount.value =
            double.tryParse(result['discount']?.toString() ?? '0') ?? 0;
        finalAmount.value =
            double.tryParse(result['final_amount']?.toString() ?? '0') ??
                (totalAmount.value - discountAmount.value);

        // Recalculate totals to update UI reactively
        calculateTotals();

        print('✅ Coupon applied successfully');
        print('💰 Original total: ${totalAmount.value}');
        print('🎫 Discount: ${discountAmount.value}');
        print('💳 Final amount: ${finalAmount.value}');

        // Show success message
        CustomSnackBar().snackBarSuccess(
            result['message'] ?? 'Coupon applied successfully!');
      } else {
        // Coupon is invalid or other error
        String errorMessage = result['message'] ?? 'Coupon validation failed';
        print('❌ Coupon error: $errorMessage');

        // Use localized error messages
        String errorType = couponService.getCouponErrorType(errorMessage);
        String localizedMessage =
            couponService.getLocalizedErrorMessage(errorType);

        CustomSnackBar().snackBarError(localizedMessage);
      }
    } catch (e) {
      print('❌ Exception applying coupon: $e');
      CustomSnackBar().snackBarError('Error applying coupon: $e');
    } finally {
      isCouponVerifying.value = false;
    }
  }

  // Remove applied coupon using API call
  Future<void> removeCoupon() async {
    try {
      print('🗑️ Removing coupon from cart controller');

      // Call the API to remove coupon (same as web version)
      var result = await couponService.removeCoupon(totalAmount.value);

      if (result['success'] == true) {
        // Update state
        appliedCoupon.value = '';
        discountAmount.value = 0;
        finalAmount.value = totalAmount.value;
        isCouponApplied.value = false;
        couponController.clear();

        // Recalculate totals to update UI reactively
        calculateTotals();

        print('✅ Coupon removed successfully');
        print('💰 New total: ${finalAmount.value}');

        CustomSnackBar().snackBarSuccess('Coupon removed successfully');
      } else {
        print('❌ Failed to remove coupon: ${result['message']}');
        CustomSnackBar()
            .snackBarError(result['message'] ?? 'Failed to remove coupon');
      }
    } catch (e) {
      print('❌ Exception removing coupon: $e');
      CustomSnackBar().snackBarError('Error removing coupon: $e');
    }
  }

  // Reset coupon state
  void resetCoupon() {
    appliedCoupon.value = '';
    discountAmount.value = 0;
    finalAmount.value = totalAmount.value;
    isCouponApplied.value = false;
    couponController.clear();
  }

  // Complete order
  Future<void> completeOrder() async {
    if (cartItems.isEmpty) {
      CustomSnackBar().snackBarWarning('Your cart is empty');
      return;
    }

    try {
      isProcessingOrder.value = true;

      print('🛒 Completing order...');
      print('💳 Applied coupon: ${appliedCoupon.value}');
      print('💰 Final amount: ${finalAmount.value}');

      String? couponCode = isCouponApplied.value ? appliedCoupon.value : null;
      var result = await cartService.makeOrder(couponCode: couponCode);

      if (result['success'] == true) {
        print('✅ Order completed successfully');

        // Clear cart and reset state first
        cartItems.clear();
        cartCount.value = 0;
        resetCoupon();

        // Show success message
        CustomSnackBar().snackBarSuccess(
            '🎉 ' + (result['message'] ?? 'Order completed successfully!'));

        // Refresh my courses
        final MyCourseController myCourseController =
            Get.put(MyCourseController());
        await myCourseController.fetchMyCourse();

        // Navigate directly to courses page - no empty cart page!
        Get.offAll(() => MainNavigationPage()); // Go to main navigation
        await Future.delayed(Duration(milliseconds: 300));
        Get.find<DashboardController>()
            .changeTabIndex(1); // Switch to Courses tab

        // Show success message after navigation
        await Future.delayed(Duration(milliseconds: 300));
        CustomSnackBar()
            .snackBarSuccess('Your courses are now available in "My Courses"!');
      } else {
        print('❌ Order completion failed: ${result['message']}');
        CustomSnackBar().snackBarError(result['message'] ?? 'Order failed');
      }
    } catch (e) {
      print('❌ Exception completing order: $e');
      CustomSnackBar().snackBarError('Error completing order: $e');
    } finally {
      isProcessingOrder.value = false;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      bool success = await cartService.clearCart();
      if (success) {
        cartItems.clear();
        cartCount.value = 0;
        resetCoupon();
        CustomSnackBar().snackBarSuccess('Cart cleared');
      }
    } catch (e) {
      CustomSnackBar().snackBarError('Error clearing cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get cart summary
  String getCartSummary() {
    if (cartItems.isEmpty) return 'Cart is empty';

    String summary =
        '${cartItems.length} item${cartItems.length > 1 ? 's' : ''}';
    if (isCouponApplied.value) {
      summary += ' with coupon applied';
    }
    return summary;
  }

  // Check if course is in cart
  bool isCourseInCart(int courseId) {
    return cartItems.any((item) => item.courseId == courseId);
  }

  // Get cart item by course ID
  CartList? getCartItemByCourseId(int courseId) {
    try {
      return cartItems.firstWhere((item) => item.courseId == courseId);
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}
