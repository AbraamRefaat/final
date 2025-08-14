// Flutter imports:
import 'dart:math';
import 'package:flutter/material.dart';
// Package imports:

import 'package:get/get.dart';
// Project imports:
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Views/Home/Course/all_course_view.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/Home/Quiz/quiz_details_page_view/quiz_details_page_view.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/my_quiz_details_view/my_quiz_details_view.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/DefaultLoadingWidget.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/utils/widgets/ImageSlider.dart';
import 'package:untitled2/utils/widgets/LoadingSkeletonItemWidget.dart';
import 'package:untitled2/utils/widgets/SingleCardItemWidget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/Views/Home/Course/course_level_category_page.dart';
import 'package:untitled2/utils/responsive_helper.dart';

Widget sellAllText() {
  return Text(
    TranslationHelper.tr("See All"),
    style: Get.textTheme.titleSmall?.copyWith(
      color: Get.theme.primaryColor,
    ),
  );
}

class HomePage extends GetView<HomeController> {
  Color selectColor(int position) {
    Color c = Color(0xff569AFF);
    if (position % 4 == 0) c = Color(0xff569AFF);
    if (position % 4 == 1) c = Color(0xff6D55FF);
    if (position % 4 == 2) c = Color(0xffD764FF);
    if (position % 4 == 3) c = Color(0xffFF9800);
    return c;
  }

  // Helper method to get translated category names
  String _getTranslatedCategoryName(String categoryName) {
    // Check if this is one of our special categories that need translation
    switch (categoryName) {
      case 'First Secondary':
        return TranslationHelper.tr('First Secondary');
      case 'Second Secondary':
        return TranslationHelper.tr('Second Secondary');
      case 'Third Secondary':
        return TranslationHelper.tr('Third Secondary');
      default:
        // For other categories, return the original name
        return categoryName;
    }
  }

  Future<void> refresh() async {
    controller.onInit();
  }

  @override
  Widget build(BuildContext context) {
    // double width;
    // double percentageWidth;
    double height;
    double percentageHeight;

    // width = MediaQuery.of(context).size.width;
    // percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;

    return ResponsiveHelper.responsiveWrapper(
        context: context,
        child: LoaderOverlay(
          useDefaultLoading: false,
          // overlayWidget: defaultLoadingWidget,
          overlayWidgetBuilder: (_) => defaultLoadingWidget,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBarWidget(
                showSearch: true,
                goToSearch: true,
                showBack: false,
                showFilterBtn: false,
              ),
              body: Container(
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      ImageSlider(),
                      SizedBox(
                        height: 15,
                      ),

                      /// TOP CATEGORIES
                      Container(
                          margin: ResponsiveHelper.getAdaptivePadding(context,
                                  horizontal: 20, vertical: 0)
                              .copyWith(
                            bottom: ResponsiveHelper.getAdaptiveSpacing(
                                context, 14.72),
                          ),
                          child:
                              Texth1(TranslationHelper.tr('Top Categories'))),
                      Container(
                          margin: ResponsiveHelper.getAdaptivePadding(context,
                                  horizontal: 20, vertical: 0)
                              .copyWith(
                            left: Get.locale == Locale('ar')
                                ? 0
                                : ResponsiveHelper.getAdaptiveSpacing(
                                    context, 20),
                            right: Get.locale == Locale('ar')
                                ? ResponsiveHelper.getAdaptiveSpacing(
                                    context, 20)
                                : 0,
                          ),
                          child: Obx(() {
                            if (controller.isLoading.value)
                              return Container(
                                height: ResponsiveHelper.getAdaptiveHeight(
                                    context, 80),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        width:
                                            ResponsiveHelper.getAdaptiveSpacing(
                                                context, 12),
                                      );
                                    },
                                    itemBuilder:
                                        (BuildContext context, int indexCat) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          height: ResponsiveHelper
                                              .getAdaptiveHeight(context, 80),
                                          width:
                                              ResponsiveHelper.getAdaptiveWidth(
                                                  context, 140),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Container(
                                                  height: percentageHeight * 1,
                                                  width: ResponsiveHelper
                                                      .getAdaptiveWidth(
                                                          context, 140),
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Container(
                                                  height:
                                                      percentageHeight * 0.5,
                                                  width: 60,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            else {
                              return Container(
                                height: ResponsiveHelper.getAdaptiveHeight(
                                    context, 80),
                                child: controller.topCatList.length == 0
                                    ? Center(
                                        child: Text(
                                        TranslationHelper.tr(
                                            'No categories available'),
                                        style: TextStyle(color: Colors.black),
                                      ))
                                    : ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: controller.topCatList.length,
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        separatorBuilder: (context, index) {
                                          return SizedBox(
                                            width: ResponsiveHelper
                                                .getAdaptiveSpacing(
                                                    context, 12),
                                          );
                                        },
                                        itemBuilder: (BuildContext context,
                                            int indexCat) {
                                          return GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: selectColor(indexCat),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0)),
                                              height: ResponsiveHelper
                                                  .getAdaptiveHeight(
                                                      context, 200),
                                              width: ResponsiveHelper
                                                  .getAdaptiveWidth(
                                                      context, 140),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 8,
                                                        top: 18,
                                                        right: 8,
                                                        bottom: 18),
                                                    child: Center(
                                                      child: CatTitle(
                                                          _getTranslatedCategoryName(
                                                              controller
                                                                      .topCatList[
                                                                          indexCat]
                                                                      .name ??
                                                                  "${controller.topCatList[indexCat].name ?? ""}")),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              Get.to(() => CourseLevelCategoryPage(
                                                  _getTranslatedCategoryName(
                                                      controller
                                                              .topCatList[
                                                                  indexCat]
                                                              .name ??
                                                          "${controller.topCatList[indexCat].name ?? ""}"),
                                                  controller
                                                          .topCatList[indexCat]
                                                          .name ??
                                                      ""));
                                            },
                                          );
                                        }),
                              );
                            }
                          })),

                      /// FEATURED COURSES
                      Container(
                          margin: ResponsiveHelper.getAdaptivePadding(context,
                                  horizontal: 20, vertical: 0)
                              .copyWith(
                            left: Get.locale == Locale('ar')
                                ? ResponsiveHelper.getAdaptiveSpacing(
                                    context, 12)
                                : ResponsiveHelper.getAdaptiveSpacing(
                                    context, 20),
                            bottom: ResponsiveHelper.getAdaptiveSpacing(
                                context, 14.72),
                            top: ResponsiveHelper.getAdaptiveSpacing(
                                context, 30),
                            right: Get.locale == Locale('ar')
                                ? ResponsiveHelper.getAdaptiveSpacing(
                                    context, 20)
                                : ResponsiveHelper.getAdaptiveSpacing(
                                    context, 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Texth1(TranslationHelper.tr("Featured Courses")),
                              Expanded(
                                child: Container(),
                              ),
                              GestureDetector(
                                child: sellAllText(),
                                onTap: () {
                                  Get.to(() => AllCourseView());
                                },
                              )
                            ],
                          )),
                      Container(
                        margin: ResponsiveHelper.getAdaptivePadding(context,
                                horizontal: 15, vertical: 0)
                            .copyWith(
                          left: Get.locale == Locale('ar')
                              ? 0
                              : ResponsiveHelper.getAdaptiveSpacing(
                                  context, 15),
                          right: Get.locale == Locale('ar')
                              ? ResponsiveHelper.getAdaptiveSpacing(context, 15)
                              : 0,
                        ),
                        child: Obx(() {
                          if (controller.isLoading.value)
                            return LoadingSkeletonItemWidget();
                          else {
                            return Container(
                              height: ResponsiveHelper.getAdaptiveHeight(
                                  context, 200),
                              child: controller.allCourse.length == 0
                                  ? Center(
                                      child: Text(
                                      TranslationHelper.tr(
                                          'No course available'),
                                      style: TextStyle(color: Colors.black),
                                    ))
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: min(
                                          10,
                                          controller.allCourse
                                              .length), // Limit to 10 items for better performance
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          width: ResponsiveHelper
                                              .getAdaptiveSpacing(context, 18),
                                        );
                                      },
                                      padding:
                                          ResponsiveHelper.getAdaptivePadding(
                                                  context,
                                                  horizontal: 5,
                                                  vertical: 0)
                                              .copyWith(
                                        left: Get.locale == Locale('ar')
                                            ? 0
                                            : ResponsiveHelper
                                                .getAdaptiveSpacing(context, 5),
                                        right: Get.locale == Locale('ar')
                                            ? ResponsiveHelper
                                                .getAdaptiveSpacing(context, 5)
                                            : 0,
                                      ),
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SingleItemCardWidget(
                                          showPricing: true,
                                          image:
                                              "${controller.allCourse[index].image}",
                                          title:
                                              controller.allCourse[index].title,
                                          subTitle: controller.allCourse[index]
                                              .assignedInstructor,
                                          price:
                                              controller.allCourse[index].price,
                                          discountPrice: controller
                                              .allCourse[index].discountPrice,
                                          onTap: () async {
                                            context.loaderOverlay.show();
                                            var course =
                                                controller.allCourse[index];

                                            // Get course details first to check for quiz content
                                            controller.courseID.value =
                                                course.id;
                                            await controller.getCourseDetails();

                                            // Check if course has quiz lessons using the course details response
                                            bool hasQuizzes = controller
                                                    .courseDetails.value.lessons
                                                    ?.any((lesson) =>
                                                        lesson.isQuiz == 1 ||
                                                        (lesson.quiz != null &&
                                                            lesson.quiz!
                                                                .isNotEmpty)) ??
                                                false;

                                            if (hasQuizzes) {
                                              // Handle as quiz course
                                              QuizController
                                                  allQuizzesController =
                                                  Get.find<
                                                      QuizController>(); // Use find instead of put

                                              allQuizzesController
                                                  .courseID.value = course.id;
                                              await allQuizzesController
                                                  .getQuizDetails();

                                              if (allQuizzesController
                                                  .isQuizBought.value) {
                                                await allQuizzesController
                                                    .getMyQuizDetails();
                                                Get.to(() =>
                                                    MyQuizDetailsPageView());
                                              } else {
                                                Get.to(() =>
                                                    QuizDetailsPageView());
                                              }
                                              context.loaderOverlay.hide();
                                            } else {
                                              // Regular course navigation (course details already loaded)
                                              controller
                                                  .selectedLessonID.value = 0;
                                              Get.to(() => CourseDetailsPage());
                                              context.loaderOverlay.hide();
                                            }
                                          },
                                        );
                                      }),
                            );
                          }
                        }),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveHeight(context, 80),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
