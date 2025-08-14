// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:octo_image/octo_image.dart';

// Project imports:
import 'package:untitled2/Controller/cart_controller.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/translation_helper.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController cartController = Get.put(CartController());
  final DashboardController dashboardController =
      Get.put(DashboardController());

  late FocusNode couponFocusNode;

  @override
  void initState() {
    super.initState();
    couponFocusNode = FocusNode();
  }

  @override
  void dispose() {
    couponFocusNode.dispose();
    super.dispose();
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
      body: Obx(() {
        if (cartController.isLoading.value) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Cart Items (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Cart items list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(12),
                          itemCount: cartController.cartItems.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = cartController.cartItems[index];
                            return _buildCartItem(item);
                          },
                        ),
                        // Coupon Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: _buildCouponSection(),
                        ),
                        // Order Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: _buildOrderSummary(),
                        ),
                        // Add bottom padding for keyboard
                        SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 16),
                      ],
                    ),
                  ),
                ),
                // Complete Order Button - Fixed at bottom
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartController.isProcessingOrder.value
                            ? null
                            : cartController.completeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: cartController.isProcessingOrder.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                      TranslationHelper.tr("Processing order")),
                                ],
                              )
                            : Text(TranslationHelper.tr("Complete Order")),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            TranslationHelper.tr("Empty Cart"),
            style: Get.textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            TranslationHelper.tr("No items in your cart"),
            style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text(TranslationHelper.tr("Continue Shopping")),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: cartController.cartItems.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cartController.cartItems[index];
        return _buildCartItem(item);
      },
    );
  }

  Widget _buildCartItem(item) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(8), // Reduced padding
        child: Row(
          children: [
            // Course Image (smaller)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 60,
                height: 45,
                color: Colors.grey.shade300,
                child: item.course?.image != null
                    ? OctoImage(
                        image: NetworkImage(item.course!.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child:
                                Icon(Icons.image, color: Colors.grey.shade600),
                          );
                        },
                      )
                    : Icon(Icons.image, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(width: 10),
            // Course Details (smaller font)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.course?.title ?? 'Course Title',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    item.course?.user?.name ?? 'Instructor',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    // Always show price in EGP, no localization
                    '${item.price?.toStringAsFixed(2) ?? '0.00'} EGP',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              onPressed: () {
                cartController
                    .removeFromCart(item.id); // Use cart item id for removal
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 22,
              ),
              tooltip: TranslationHelper.tr("Remove from Cart"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
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
          if (cartController.isCouponApplied.value) ...[
            _buildAppliedCoupon(),
          ] else ...[
            _buildCouponInput(),
          ],
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
                  cartController.appliedCoupon.value,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await cartController.removeCoupon();
              setState(() {});
            },
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
          controller: cartController.couponController,
          focusNode: couponFocusNode,
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
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: cartController.isCouponVerifying.value
                ? null
                : () async {
                    await cartController.applyCoupon();
                    couponFocusNode.unfocus();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: cartController.isCouponVerifying.value
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
                      Text(TranslationHelper.tr("Processing order")),
                    ],
                  )
                : Text(TranslationHelper.tr("Apply Coupon")),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
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
            TranslationHelper.tr("Order Summary"),
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _buildSummaryRow(
            TranslationHelper.tr("Subtotal"),
            '${cartController.totalAmount.value.toStringAsFixed(2)} EGP',
          ),
          if (cartController.isCouponApplied.value) ...[
            _buildSummaryRow(
              TranslationHelper.tr("Discount"),
              '- ${cartController.discountAmount.value.toStringAsFixed(2)} EGP',
              color: Colors.green,
            ),
            Divider(height: 20),
            _buildSummaryRow(
              TranslationHelper.tr("Final Amount"),
              '${cartController.finalAmount.value.toStringAsFixed(2)} EGP',
              isTotal: true,
            ),
          ] else ...[
            Divider(height: 20),
            _buildSummaryRow(
              TranslationHelper.tr("Total"),
              '${cartController.totalAmount.value.toStringAsFixed(2)} EGP',
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? Get.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            TranslationHelper.tr("Subtotal"),
            '${cartController.totalAmount.value.toStringAsFixed(2)} EGP',
            isTotal: true,
          ),
          if (cartController.isCouponApplied.value) ...[
            _buildSummaryRow(
              TranslationHelper.tr("Discount"),
              '- ${cartController.discountAmount.value.toStringAsFixed(2)} EGP',
              color: Colors.green,
            ),
            Divider(height: 20),
            _buildSummaryRow(
              TranslationHelper.tr("Final Amount"),
              '${cartController.finalAmount.value.toStringAsFixed(2)} EGP',
              isTotal: true,
            ),
          ] else ...[
            Divider(height: 20),
            _buildSummaryRow(
              TranslationHelper.tr("Total"),
              '${cartController.totalAmount.value.toStringAsFixed(2)} EGP',
              isTotal: true,
            ),
          ],
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartController.isProcessingOrder.value
                  ? null
                  : cartController.completeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: cartController.isProcessingOrder.value
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
                        Text(TranslationHelper.tr("Processing order")),
                      ],
                    )
                  : Text(TranslationHelper.tr("Complete Order")),
            ),
          ),
        ],
      ),
    );
  }
}
