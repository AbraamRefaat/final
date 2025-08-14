// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/NewControllerAndModels/controllers/course_by_category_controller.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/Home/Quiz/quiz_details_page_view/quiz_details_page_view.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/my_course_details_view.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/my_quiz_details_view/my_quiz_details_view.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/DefaultLoadingWidget.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/utils/widgets/SingleCardItemWidget.dart';
import 'package:loader_overlay/loader_overlay.dart';

// ignore: must_be_immutable
class CourseCategoryPage extends StatelessWidget {
  String title;
  int catIndex;

  CourseCategoryPage(this.title, this.catIndex);

  double? width;
  double? percentageWidth;
  double? height;
  double? percentageHeight;
  final CourseByCategoryIdNewController _controller =
      Get.put(CourseByCategoryIdNewController());
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Fetch courses on widget build
    _controller.fetchCourses(catIndex);

    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) => defaultLoadingWidget,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBarWidget(
            showSearch: true,
            goToSearch: true,
            showBack: true,
            showFilterBtn: false,
          ),
          body: Obx(() {
            if (_controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if (_controller.courses.isEmpty) {
              return Center(
                  child: Text(TranslationHelper.tr('No Data Available')));
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  mainAxisExtent: 210,
                ),
                itemCount: _controller.courses.length,
                itemBuilder: (context, index) {
                  final course = _controller.courses[index];
                  return SingleItemCardWidget(
                    showPricing: true,
                    image: course.image,
                    title: course.title,
                    price: course.price,
                    discountPrice: course.discountPrice,
                    onTap: () async {
                      context.loaderOverlay.show();

                      // Get course details first to check for quiz content
                      _homeController.courseID.value = course.id;
                      await _homeController.getCourseDetails();

                      // Check if course has quiz lessons using the course details response
                      bool hasQuizzes = _homeController
                              .courseDetails.value.lessons
                              ?.any((lesson) =>
                                  lesson.isQuiz == 1 ||
                                  (lesson.quiz != null &&
                                      lesson.quiz!.isNotEmpty)) ??
                          false;

                      if (hasQuizzes) {
                        // Handle as quiz course
                        final QuizController allQuizzesController = Get.find<
                            QuizController>(); // Use find instead of put

                        allQuizzesController.courseID.value = course.id;
                        await allQuizzesController.getQuizDetails();

                        if (allQuizzesController.isQuizBought.value) {
                          await allQuizzesController.getMyQuizDetails();
                          Get.to(() => MyQuizDetailsPageView());
                        } else {
                          Get.to(() => QuizDetailsPageView());
                        }
                        context.loaderOverlay.hide();
                      } else {
                        // Regular course navigation (course details already loaded)
                        if (_homeController.isCourseBought.value) {
                          final MyCourseController myCoursesController =
                              Get.put(MyCourseController());

                          myCoursesController.courseID.value = course.id;
                          myCoursesController.selectedLessonID.value = 0;
                          myCoursesController.myCourseDetailsTabController
                              .controller?.index = 0;

                          await myCoursesController.getCourseDetails();
                          Get.to(() => MyCourseDetailsView());
                          context.loaderOverlay.hide();
                        } else {
                          Get.delete<HomeController>(force: true);
                          Get.to(() => CourseDetailsPage(),
                              arguments: {'courseId': course.id});
                          context.loaderOverlay.hide();
                        }
                      }
                    },
                  );
                },
              );
            }
          }),
        ),
      ),
    );
  }
}
