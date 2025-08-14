// Dart imports:
import 'dart:convert';
import 'dart:io';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/cart_controller.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/utils/translation_helper.dart';

Widget descriptionWidget({
  required HomeController controller,
  required DashboardController dashboardController,
  required double percentageHeight,
  required double percentageWidth,
  required BuildContext context,
}) {
  final CartController cartController = Get.put(CartController());

  void applyCoupon() async {
    try {
      // Add course to cart and navigate to checkout
      await cartController.addToCart(controller.courseDetails.value.id!);
      Get.toNamed('/checkout');
    } catch (e) {
      CustomSnackBar()
          .snackBarError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  return Directionality(
    textDirection: Get.locale?.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr,
    child: Obx(
      () => Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: applyCoupon,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Color(0xff0070f3),
                      ),
                      child: Text(
                        TranslationHelper.tr('Add to Cart'),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
