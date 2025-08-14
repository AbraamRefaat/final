import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/NewControllerAndModels/models/course_model.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/Home/Quiz/quiz_details_page_view/quiz_details_page_view.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/my_quiz_details_view/my_quiz_details_view.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/SingleCardItemWidget.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CourseLevelCategoryPage extends StatefulWidget {
  final String categoryTitle;
  final String levelName;

  CourseLevelCategoryPage(this.categoryTitle, this.levelName);

  @override
  State<CourseLevelCategoryPage> createState() =>
      _CourseLevelCategoryPageState();
}

class _CourseLevelCategoryPageState extends State<CourseLevelCategoryPage> {
  final HomeController controller = Get.find<HomeController>();
  List<Course> filteredCourses = [];
  bool isLoading = true;
  int retryCount = 0;
  final int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    loadCoursesForLevel();
  }

  Future<void> loadCoursesForLevel() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    // Retry logic for reliability
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        List<Course> courses =
            await controller.getCoursesForLevel(widget.levelName);
        if (mounted) {
          setState(() {
            filteredCourses = courses;
            isLoading = false;
          });
          return; // Success, exit retry loop
        }
      } catch (e) {
        if (attempt == maxRetries) {
          // Final attempt failed
          if (mounted) {
            setState(() {
              filteredCourses = [];
              isLoading = false;
            });
          }
        } else {
          // Wait before retry
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.levelName,
          style: Get.textTheme.headlineSmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Clear cache and reload
          controller.clearFilterCache();
          await loadCoursesForLevel();
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredCourses.isEmpty
                ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 20),
                          Text(
                            TranslationHelper.tr('no_course_available'),
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Pull down to refresh',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.levelName,
                                style: Get.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${filteredCourses.length} ${TranslationHelper.tr('courses')}',
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              var course = filteredCourses[index];
                              return SingleItemCardWidget(
                                showPricing: true,
                                image: course.image,
                                title: course.title,
                                subTitle: course.assignedInstructor,
                                price: course.price,
                                discountPrice: course.discountPrice,
                                onTap: () async {
                                  context.loaderOverlay.show();

                                  // Get course details first to check for quiz content
                                  controller.courseID.value = course.id;
                                  await controller.getCourseDetails();

                                  // Check if course has quiz lessons using the course details response
                                  bool hasQuizzes = controller
                                          .courseDetails.value.lessons
                                          ?.any((lesson) =>
                                              lesson.isQuiz == 1 ||
                                              (lesson.quiz != null &&
                                                  lesson.quiz!.isNotEmpty)) ??
                                      false;

                                  if (hasQuizzes) {
                                    // Handle as quiz course
                                    final QuizController allQuizzesController =
                                        Get.find<
                                            QuizController>(); // Use find instead of put

                                    allQuizzesController.courseID.value =
                                        course.id;
                                    await allQuizzesController.getQuizDetails();

                                    if (allQuizzesController
                                        .isQuizBought.value) {
                                      await allQuizzesController
                                          .getMyQuizDetails();
                                      Get.to(() => MyQuizDetailsPageView());
                                    } else {
                                      Get.to(() => QuizDetailsPageView());
                                    }
                                    context.loaderOverlay.hide();
                                  } else {
                                    // Regular course navigation (course details already loaded)
                                    controller.selectedLessonID.value = 0;
                                    Get.delete<HomeController>(force: true);
                                    Get.to(() => CourseDetailsPage(),
                                        arguments: {'courseId': course.id});
                                    context.loaderOverlay.hide();
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
