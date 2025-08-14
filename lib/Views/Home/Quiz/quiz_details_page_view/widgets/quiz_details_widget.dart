// Dart imports:
import 'dart:io';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

Widget quizDetailsWidget(
    {required QuizController controller,
    required DashboardController dashboardController,
    required double percentageWidth}) {
  return ExtendedVisibilityDetector(
    uniqueKey: const Key('Tab1'),
    child: Scaffold(
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          Text(
            "${stctrl.lang["Instruction"]}" + ": ",
            style: Get.textTheme.titleMedium,
          ),
          Container(
            width: percentageWidth * 100,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: HtmlWidget(
              '''
                ${controller.quizDetails.value.quiz?.instruction ?? "${controller.quizDetails.value.quiz?.instruction}"}
                 ''',
              textStyle: Get.textTheme.titleSmall,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${stctrl.lang["Quiz Time"]}" + ":",
            style: Get.textTheme.titleMedium,
          ),
          SizedBox(
            height: 10,
          ),
          controller.quizDetails.value.quiz?.questionTimeType == 0
              ? Text(
                  "${controller.quizDetails.value.quiz?.questionTime} " +
                      "${stctrl.lang["minute(s) per question"]}",
                  style: Get.textTheme.titleSmall,
                )
              : Text(
                  "${controller.quizDetails.value.quiz?.questionTime} " +
                      "${stctrl.lang["minute(s)"]}",
                  style: Get.textTheme.titleSmall,
                ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: dashboardController.loggedIn.value
          ? controller.isQuizBought.value
              ? Container()
              : controller.quizDetails.value.price == 0
                  ? ElevatedButton(
                      child: Text(
                        "${stctrl.lang["Enroll the Quiz"]}",
                        style: Get.textTheme.titleSmall
                            ?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      style: Get.theme.elevatedButtonTheme.style,
                      onPressed: () async {
                        await controller
                            .buyNow(controller.quizDetails.value.id.toString())
                            .then((value) async {
                          if (value) {
                            await Future.delayed(Duration(seconds: 5), () {
                              Get.back();
                              dashboardController
                                  .changeTabIndex(Platform.isIOS ? 1 : 2);
                            });
                          }
                        });
                      },
                    )
                  : controller.cartAdded.value && !Platform.isIOS
                      ? ElevatedButton(
                          child: Text(
                            "${stctrl.lang["View On Cart"]}",
                            style: Get.textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            Get.back();
                            stctrl.dashboardController.persistentTabController
                                .jumpToTab(1);
                            dashboardController.changeTabIndex(1);
                            Get.back();
                          },
                        )
                      : controller.enrollLoader.value
                          ? CircularProgressIndicator(
                              color: Colors.green,
                            )
                          : ElevatedButton(
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: controller.isPurchasingIAP.value
                                    ? CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${stctrl.lang["Buy Now"]}",
                                            style: Get.textTheme.titleSmall
                                                ?.copyWith(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${controller.quizDetails.value.discountPrice == null || controller.quizDetails.value.discountPrice == 0 ? controller.quizDetails.value.price.toString() : controller.quizDetails.value.discountPrice.toString()} $appCurrency",
                                            style: Get.textTheme.titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                              ),
                              onPressed: () async {
                                if (Platform.isIOS) {
                                  try {
                                    print(
                                        "IAP Product ID ->  ${controller.quizDetails.value.iapProductId}");
                                    controller.isPurchasingIAP.value = true;
                                    final products =
                                        await Purchases.getProducts([
                                      controller
                                              .quizDetails.value.iapProductId ??
                                          ''
                                    ]);
                                    if (products.isNotEmpty) {
                                      PurchaseResult purchaseResult =
                                          await Purchases.purchaseStoreProduct(
                                              products.first);
                                      print(purchaseResult);

                                      await controller
                                          .enrollIAP(
                                              controller.quizDetails.value.id)
                                          .then((value) {
                                        Get.back();
                                        dashboardController.changeTabIndex(1);
                                      });
                                    }
                                    controller.isPurchasingIAP.value = false;
                                  } on PlatformException catch (e) {
                                    var errorCode =
                                        PurchasesErrorHelper.getErrorCode(e);
                                    if (errorCode ==
                                        PurchasesErrorCode
                                            .purchaseCancelledError) {
                                      print("Cancelled");
                                      CustomSnackBar()
                                          .snackBarWarning("Cancelled");
                                    } else if (errorCode ==
                                        PurchasesErrorCode
                                            .purchaseNotAllowedError) {
                                      CustomSnackBar().snackBarWarning(
                                          "User not allowed to purchase");
                                    } else if (errorCode ==
                                        PurchasesErrorCode
                                            .paymentPendingError) {
                                      CustomSnackBar().snackBarWarning(
                                          "Payment is pending");
                                    } else {
                                      print(e);
                                    }
                                    controller.isPurchasingIAP.value = false;
                                  } catch (e) {
                                    print(e);
                                    controller.isPurchasingIAP.value = false;
                                  }
                                } else {
                                  await controller.buyNow(controller
                                      .quizDetails.value.id
                                      .toString());
                                }
                              },
                            )
          : ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
                stctrl.dashboardController.persistentTabController.jumpToTab(1);
                dashboardController.changeTabIndex(1);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFD7598F)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${stctrl.lang["Buy Now"]}",
                    style:
                        Get.textTheme.titleSmall?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    controller.quizDetails.value.discountPrice == null ||
                            controller.quizDetails.value.discountPrice == 0
                        ? (controller.quizDetails.value.price == null ||
                                controller.quizDetails.value.price == 0
                            ? ''
                            : '${controller.quizDetails.value.price.toString()} $appCurrency')
                        : '${controller.quizDetails.value.discountPrice.toString()} $appCurrency',
                    style: Get.textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
    ),
  );
}
