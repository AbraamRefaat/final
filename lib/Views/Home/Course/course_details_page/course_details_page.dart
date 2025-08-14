// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';

import 'package:untitled2/Service/iap_service.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/widgets/curriculum_widget.dart';

import 'package:untitled2/utils/SliverAppBarTitleWidget.dart';
import 'package:untitled2/utils/widgets/course_details_flexible_space_bar.dart';
import 'package:untitled2/Views/checkout_page.dart';
import 'package:untitled2/Controller/cart_controller.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';
import 'package:untitled2/utils/screenshot_protection_helper.dart';

// ignore: must_be_immutable
class CourseDetailsPage extends StatefulWidget {
  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with TickerProviderStateMixin, ScreenshotProtectionMixin {
  GetStorage userToken = GetStorage();

  String tokenKey = "token";

  double width = 0;

  double percentageWidth = 0;

  double height = 0;

  double percentageHeight = 0;

  bool isReview = false;

  bool isSignIn = true;

  bool playing = false;

  HomeController? _controller;
  late final HomeController controller;

  late TabController _singleTabController;

  @override
  void initState() {
    super.initState();
    
    // Enable screenshot protection for course content
    enableScreenshotProtection();
    
    try {
      _controller = Get.find<HomeController>();
    } catch (e) {
      _controller = Get.put(HomeController());
    }
    controller = _controller!;
    _loadCourse();
    if (Platform.isIOS) {
      controller.isPurchasingIAP.value = false;
      IAPService().initPlatformState();
    }
    _singleTabController = TabController(length: 1, vsync: this);
  }

  void _loadCourse() async {
    final args = Get.arguments;
    controller.shouldForceReload = true; // Force reload every time
    if (args != null && args['courseId'] != null) {
      controller.courseID.value = args['courseId'];
      await controller.getCourseDetails();
    } else if (args != null && args['goToCourseId'] != null) {
      controller.courseID.value = args['goToCourseId'];
      await controller.getCourseDetails();
    } else if (controller.courseID.value != null &&
        controller.courseID.value != 0) {
      await controller.getCourseDetails();
    }
  }

  @override
  void dispose() {
    _singleTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.put(DashboardController());

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // ignore: unused_local_variable
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight;

    width = MediaQuery.of(context).size.width;
    percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;

    // Custom back behavior if navigated from quiz answers/result
    return WillPopScope(
      onWillPop: () async {
        final args = Get.arguments;
        if (args != null && args['goToCourseId'] != null) {
          Get.offAll(() => MainNavigationPage());
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: LoaderOverlay(
          useDefaultLoading: false,
          overlayWidgetBuilder: (_) => Center(
            child: SpinKitPulse(
              color: Get.theme.primaryColor,
              size: 30.0,
            ),
          ),
          child: Obx(() {
            if (controller.isCourseLoading.value)
              return Center(
                child: CupertinoActivityIndicator(),
              );
            return NestedScrollView(
              // floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 280.0,
                    automaticallyImplyLeading: false,
                    titleSpacing: 20,
                    title: SliverAppBarTitleWidget(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.arrow_back_outlined,
                              color: Get.textTheme.titleMedium?.color,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.courseDetails.value.title
                                          ?.isNotEmpty ==
                                      true
                                  ? controller.courseDetails.value.title!
                                  : "No Title",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Get.textTheme.titleMedium,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        background: CourseDetailsFlexilbleSpaceBar(
                            controller.courseDetails.value)),
                  ),
                ];
              },
              // pinnedHeaderSliverHeightBuilder: () {
              //   return pinnedHeaderHeight;
              // },
              body: Column(
                children: <Widget>[
                  // Buy Now button section in white area
                  Container(
                    color: Get.theme.scaffoldBackgroundColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child:
                        _buildPurchaseSection(controller, dashboardController),
                  ),
                  // TabBar (hardcoded single tab)
                  TabBar(
                    labelColor: Colors.white,
                    tabs: [
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.only(left: 12.0, right: 12),
                          child: Text('Curriculum'),
                        ),
                      ),
                    ],
                    controller: _singleTabController,
                    indicator: Get.theme.tabBarTheme.indicator,
                    automaticIndicatorColorAdjustment: true,
                    isScrollable: false,
                    labelStyle: Get.textTheme.titleSmall,
                    unselectedLabelStyle: Get.textTheme.titleSmall,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _singleTabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        curriculumWidget(controller, dashboardController),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPurchaseSection(
      HomeController controller, DashboardController dashboardController) {
    final CartController cartController = Get.put(CartController());

    return Obx(() {
      // Check if user is logged in
      if (!dashboardController.loggedIn.value) {
        return _buildLoginPrompt();
      }

      // Check if course is already purchased (enrolled)
      bool isEnrolled = controller.courseDetails.value.enrolls?.any((enroll) =>
              enroll.userId == dashboardController.profileData.id) ??
          false;

      if (isEnrolled) {
        return _buildEnrolledMessage();
      }

      // Check if course is free
      if (controller.courseDetails.value.price != null &&
          controller.courseDetails.value.price == 0) {
        return _buildFreeCourseButton();
      }

      // Show purchase options
      return _buildPurchaseButtons(controller, cartController);
    });
  }

  Widget _buildLoginPrompt() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          CustomSnackBar().snackBarWarning(
              TranslationHelper.tr("Please login to purchase"));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          TranslationHelper.tr("Please Log in"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeCourseButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Free course action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          TranslationHelper.tr("Free Course"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEnrolledMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            TranslationHelper.tr("Course already purchased"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButtons(
      HomeController controller, CartController cartController) {
    return Column(
      children: [
        // Price display - only show if price is available
        if (controller.courseDetails.value.price != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${controller.courseDetails.value.price?.toStringAsFixed(2)} ${stctrl.lang["Currency"] ?? "£"}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Get.textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 8),
        // Single Buy Now button
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              _handleDirectPurchase(controller);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              TranslationHelper.tr("Buy Now"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDirectPurchase(HomeController controller) async {
    try {
      // Get the cart controller
      final CartController cartController = Get.put(CartController());

      // Add course to cart using the new API endpoint
      bool success = await cartController
          .addToCart(controller.courseDetails.value.id ?? 0);

      if (success) {
        // Navigate to cart/checkout page
        Get.to(() => CheckoutPage());
      } else {
        CustomSnackBar().snackBarError('Failed to add course to cart');
      }
    } catch (e) {
      CustomSnackBar().snackBarError('Error: $e');
    }
  }
}
