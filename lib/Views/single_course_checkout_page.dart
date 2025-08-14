// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Service/coupon_service.dart';
import 'package:untitled2/Service/cart_service.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';
import 'package:untitled2/utils/widgets/responsive_coupon_widget.dart';

class SingleCourseCheckoutPage extends StatefulWidget {
  final CourseMain course;

  const SingleCourseCheckoutPage({Key? key, required this.course})
      : super(key: key);

  @override
  _SingleCourseCheckoutPageState createState() =>
      _SingleCourseCheckoutPageState();
}

class _SingleCourseCheckoutPageState extends State<SingleCourseCheckoutPage> {
  final TextEditingController couponController = TextEditingController();
  final CouponService couponService = CouponService();
  final CartService cartService = CartService();
  final DashboardController dashboardController =
      Get.put(DashboardController());

  GetStorage userToken = GetStorage();
  String tokenKey = "token";

  var isProcessingOrder = false.obs;
  var isCouponVerifying = false.obs;
  var totalAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var finalAmount = 0.0.obs;
  var appliedCoupon = ''.obs;
  var isCouponApplied = false.obs;

  // Local state for immediate UI updates
  bool _localIsCouponApplied = false;
  String _localAppliedCoupon = '';

  // Simple flag to force UI rebuild
  bool _forceRebuild = false;

  @override
  void initState() {
    super.initState();
    totalAmount.value = widget.course.price?.toDouble() ?? 0.0;
    finalAmount.value = totalAmount.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Add this to handle keyboard properly
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          TranslationHelper.tr("Your order"),
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.textTheme.titleMedium?.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseItem(),
                        SizedBox(height: 20),
                        _buildCouponSection(),
                        SizedBox(height: 30),
                        _buildCompleteOrderButton(),
                        SizedBox(
                            height: 30), // Extra space from bottom navigation
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildCourseItem() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Course Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: Colors.grey.shade300,
                child: widget.course.image != null
                    ? CachedNetworkImage(
                        imageUrl: widget.course.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: Icon(Icons.image, color: Colors.grey.shade600),
                        ),
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        maxWidthDiskCache: 300,
                        maxHeightDiskCache: 300,
                      )
                    : Icon(Icons.image, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(width: 16),
            // Course Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title ?? 'Course Title',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.course.user?.name ?? 'Instructor',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${stctrl.lang["Course Price"]}: ${widget.course.price?.toStringAsFixed(2) ?? '0.00'} ${stctrl.lang["Currency"] ?? "£"}',
                    style: Get.textTheme.titleSmall?.copyWith(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    // Use the flag to force rebuild
    _forceRebuild;

    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationHelper.tr("Have a coupon?"),
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _localIsCouponApplied ? _buildAppliedCoupon() : _buildCouponInput(),
        ],
      ),
    );
  }

  Widget _buildAppliedCoupon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300, width: 1),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationHelper.tr("Coupon Applied"),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _localAppliedCoupon,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _removeCoupon,
            child: Text(
              TranslationHelper.tr("Remove"),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Column(
      children: [
        TextField(
          controller: couponController,
          decoration: InputDecoration(
            hintText: TranslationHelper.tr("Enter Coupon Code"),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Get.theme.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onSubmitted: (_) async {
            // Close keyboard immediately
            FocusScope.of(context).unfocus();

            // Force UI update
            setState(() {});

            // Apply coupon
            await _applyCoupon();

            // Force another UI update after coupon is applied
            setState(() {});
          },
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isCouponVerifying.value
                ? null
                : () async {
                    // Close keyboard immediately
                    FocusScope.of(context).unfocus();

                    // Force UI update
                    setState(() {});

                    // Apply coupon
                    await _applyCoupon();

                    // Force another UI update after coupon is applied
                    setState(() {});
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isCouponVerifying.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(TranslationHelper.tr("Verifying")),
                    ],
                  )
                : Text(TranslationHelper.tr("Apply Coupon")),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteOrderButton() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isProcessingOrder.value ? null : _completeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isProcessingOrder.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(TranslationHelper.tr("Processing Purchase")),
                  ],
                )
              : Text(
                  TranslationHelper.tr("🔓 Unlock Course"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _applyCoupon() async {
    if (couponController.text.isEmpty) {
      return;
    }

    if (!couponService.isValidCouponFormat(couponController.text)) {
      return;
    }

    try {
      isCouponVerifying.value = true;

      var result = await couponService.applyCoupon(
          couponController.text, totalAmount.value);

      if (result['success'] == true) {
        // Update both GetX and local state immediately
        appliedCoupon.value = couponController.text;
        discountAmount.value =
            double.tryParse(result['discount']?.toString() ?? '0') ?? 0;
        finalAmount.value =
            double.tryParse(result['final_amount']?.toString() ?? '0') ??
                (totalAmount.value - discountAmount.value);
        isCouponApplied.value = true;

        // Update local state for immediate UI
        _localIsCouponApplied = true;
        _localAppliedCoupon = couponController.text;

        // Toggle flag to force rebuild
        _forceRebuild = !_forceRebuild;

        // Force UI update immediately
        if (mounted) {
          setState(() {});
        }

        // Coupon applied successfully
      } else {
        String errorType =
            couponService.getCouponErrorType(result['message'] ?? '');
        String localizedMessage =
            couponService.getLocalizedErrorMessage(errorType);
        // Error applying coupon
      }
    } catch (e) {
      // Error applying coupon
    } finally {
      isCouponVerifying.value = false;
    }
  }

  Future<void> _removeCoupon() async {
    try {
      print('🗑️ Removing coupon from checkout page');

      // Call the API to remove coupon (same as web version)
      var result = await couponService.removeCoupon(totalAmount.value);

      if (result['success'] == true) {
        // Update GetX reactive variables - this will automatically update UI
        appliedCoupon.value = '';
        discountAmount.value = 0;
        finalAmount.value = totalAmount.value;
        isCouponApplied.value = false;

        // Also update local state for consistency
        _localIsCouponApplied = false;
        _localAppliedCoupon = '';

        couponController.clear();

        // Toggle flag to force rebuild
        _forceRebuild = !_forceRebuild;

        // Force UI update multiple times
        if (mounted) {
          setState(() {});
          await Future.delayed(Duration(milliseconds: 10));
          setState(() {});
          await Future.delayed(Duration(milliseconds: 10));
          setState(() {});
        }

        print('✅ Coupon removed successfully');
        print('💰 New total: ${finalAmount.value}');
        print(
            '🔄 Local state updated: _localIsCouponApplied = $_localIsCouponApplied');
        print(
            '🔄 Local state updated: _localAppliedCoupon = "$_localAppliedCoupon"');
        print(
            '🔄 GetX state updated: isCouponApplied = ${isCouponApplied.value}');
        print(
            '🔄 GetX state updated: appliedCoupon = "${appliedCoupon.value}"');
      } else {
        print('❌ Failed to remove coupon: ${result['message']}');
        // Show error message
        // You can add a snackbar here if needed
      }
    } catch (e) {
      print('❌ Exception removing coupon: $e');
      // Show error message
      // You can add a snackbar here if needed
    }
  }

  Future<void> _completeOrder() async {
    try {
      isProcessingOrder.value = true;

      // Check if coupon is required but not applied
      if (!isCouponApplied.value) {
        return;
      }

      // Debug: Check authentication and course info
      final DashboardController dashController =
          Get.find<DashboardController>();

      String? token = userToken.read(tokenKey);

      // Step 1: Prepare course for purchase (backend requirement)

      bool courseReady = await cartService.addToCart(widget.course.id ?? 0);
      if (!courseReady) {
        return;
      }
      // Step 2: Complete purchase with coupon to unlock course
      var result = await cartService.makeOrder(couponCode: appliedCoupon.value);

      if (result['success'] == true) {
        // Course unlocked successfully!

        // Step 3: Refresh courses to show the unlocked course
        try {
          final MyCourseController myCourseController =
              Get.put(MyCourseController());
          await myCourseController.fetchMyCourse();
        } catch (e) {}

        // Navigate directly to courses page - no empty cart page!
        Get.offAll(() => MainNavigationPage()); // Go to main navigation
        await Future.delayed(Duration(milliseconds: 300));
        Get.find<DashboardController>()
            .changeTabIndex(1); // Switch to Courses tab

        // Show success message after navigation
        await Future.delayed(Duration(milliseconds: 300));
        CustomSnackBar().snackBarSuccess(TranslationHelper.tr(
            'You can now access your course in "My Courses"'));
      } else {
        // Show exact error message from your API
        String errorMessage =
            result['message'] ?? TranslationHelper.tr('Course unlock failed');

        // Display the exact error message from your backend
        CustomSnackBar().snackBarError('❌ ' + errorMessage);
      }
    } catch (e) {
      CustomSnackBar().snackBarError(
          TranslationHelper.tr('❌ Error unlocking course. Please try again.'));
    } finally {
      isProcessingOrder.value = false;
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}
