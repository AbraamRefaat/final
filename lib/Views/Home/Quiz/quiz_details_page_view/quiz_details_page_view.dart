// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Package imports:

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Controller/quiz_details_tab_controller.dart';
import 'package:untitled2/Views/Home/Quiz/quiz_details_page_view/widgets/question_answer_widget.dart';
import 'package:untitled2/Views/Home/Quiz/quiz_details_page_view/widgets/quiz_details_widget.dart';
import 'package:untitled2/utils/SliverAppBarTitleWidget.dart';
import 'package:untitled2/utils/styles.dart';

import '../../../../Service/iap_service.dart';
import '../../../../utils/widgets/course_details_flexible_space_bar.dart';

/// Extract only the Arabic title from quiz title (remove ": en" part)
String? _getQuizTitle(dynamic title) {
  if (title == null) return null;

  String titleStr = title.toString();

  // Remove ": en" part if it exists
  if (titleStr.contains(': en')) {
    return titleStr.replaceAll(': en', '').trim();
  }

  return titleStr;
}

// ignore: must_be_immutable
class QuizDetailsPageView extends StatefulWidget {
  @override
  State<QuizDetailsPageView> createState() => _QuizDetailsPageViewState();
}

class _QuizDetailsPageViewState extends State<QuizDetailsPageView> {
  final QuizController controller =
      Get.find<QuizController>(); // Use find instead of put

  GetStorage userToken = GetStorage();

  String tokenKey = "token";

  double width = 0;

  double percentageWidth = 0;

  double height = 0;

  double percentageHeight = 0;

  bool isReview = false;

  bool isSignIn = true;

  bool playing = false;

  @override
  void initState() {
    if (Platform.isIOS) {
      controller.isPurchasingIAP.value = false;
      IAPService().initPlatformState();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.put(DashboardController());

    final QuizDetailsTabController _tabx = Get.put(QuizDetailsTabController());

    // ignore: unused_local_variable
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    width = MediaQuery.of(context).size.width;
    percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;

    return Scaffold(
      body: Obx(() {
        if (controller.isQuizLoading.value)
          return Center(
            child: CupertinoActivityIndicator(),
          );
        return NestedScrollView(
          // floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 280.0,
                automaticallyImplyLeading: false,
                titleSpacing: 20,
                title: SliverAppBarTitleWidget(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getQuizTitle(controller.quizDetails.value.title) ??
                              "Quiz",
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
                        controller.quizDetails.value)),
              ),
            ];
          },
          // pinnedHeaderSliverHeightBuilder: () {
          //   return pinnedHeaderHeight;
          // },
          body: Column(
            children: <Widget>[
              TabBar(
                labelColor: Colors.white,
                tabs: _tabx.myTabs,
                unselectedLabelColor: AppStyles.unSelectedTabTextColor,
                controller: _tabx.controller,
                indicator: Get.theme.tabBarTheme.indicator,
                automaticIndicatorColorAdjustment: true,
                isScrollable: false,
                labelStyle: Get.textTheme.titleSmall,
                unselectedLabelStyle: Get.textTheme.titleSmall,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabx.controller,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    quizDetailsWidget(
                        controller: controller,
                        dashboardController: dashboardController,
                        percentageWidth: percentageWidth),
                    questionAnswerWidget(controller, dashboardController),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
