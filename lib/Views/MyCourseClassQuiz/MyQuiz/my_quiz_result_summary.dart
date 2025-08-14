import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/utils/translation_helper.dart';

import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/quiz_result_screen.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/quiz_answers_view.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class MyQuizResultSummary extends StatefulWidget {
  @override
  _MyQuizResultSummaryState createState() => _MyQuizResultSummaryState();
}

class _MyQuizResultSummaryState extends State<MyQuizResultSummary> {
  QuestionController _questionController = Get.put(QuestionController());

  bool _isNavigating = false;

  void _handleBackToCourse() async {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
    });
    // Reset HomeController state before navigating
    final homeController = Get.find<HomeController>();
    homeController.resetCourseDetails();
    final courseId = _questionController.quiz.value.courseId ??
        _questionController.quiz.value.id;
    if (courseId != null) {
      await Get.offAll(() => MainNavigationPage(),
          arguments: {'goToCourseId': courseId});
    } else {
      await Get.offAll(() => MainNavigationPage());
    }
    setState(() {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size(Get.width, 60),
          child: AppBar(
            // backgroundColor: Color(0xff18294d),
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Row(
              children: [
                Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_sharp,
                    ),
                    onPressed: () {
                      // Fix: Navigate back to course page instead of Get.back() twice
                      final courseId =
                          _questionController.quiz.value.courseId ??
                              _questionController.quiz.value.id;
                      if (courseId != null) {
                        Get.offAll(() => MainNavigationPage(),
                            arguments: {'goToCourseId': courseId});
                      } else {
                        Get.offAll(() => MainNavigationPage());
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.centerLeft,
                  width: 80,
                  height: 30,
                  child: Image.asset(
                    'images/$appLogo',
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              // color: Color(0xff18294d),
              width: Get.width,
              height: Get.height,
            ),
            Obx(() {
              if (_questionController.quizResultLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Get.theme.primaryColor,
                  ),
                );
              } else {
                DateTime start =
                    _questionController.questionResult.value.data?.createdAt ??
                        DateTime(0);
                DateTime end =
                    _questionController.questionResult.value.data?.endAt ??
                        DateTime(0);
                // ignore: unused_local_variable
                var diff = start.difference(end);

                var correctAns = 0;
                var skipped = 0;
                _questionController.questionResult.value.data?.questions
                    ?.forEach((element) {
                  if (element.isWrong == false) {
                    correctAns++;
                  }
                  if (element.isSubmit == false) {
                    skipped++;
                  }
                });
                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    SizedBox(height: 20),
                    Image.asset(
                      "images/quiz.png",
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        TranslationHelper.tr(
                            "Congratulations! You've completed Quiz Test"),
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _questionController.questionResult.value.data?.publish == 1
                        ? Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_sharp,
                                        size: 22,
                                        color: Color(0xff6FDC43),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            TranslationHelper.tr("Correct"),
                                            style: Get.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            "$correctAns/${_questionController.questionResult.value.data?.questions?.length}",
                                            style: Get.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.cancel_rounded,
                                        size: 22,
                                        color: Color(0xffFF1414),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            TranslationHelper.tr("Wrong"),
                                            style: Get.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            "${(_questionController.questionResult.value.data?.questions?.length ?? 0) - correctAns}/ ${_questionController.questionResult.value.data?.questions?.length}",
                                            style: Get.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.circle_outlined,
                                        size: 22,
                                        color: Color(0xffFF1414),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            TranslationHelper.tr("Skipped"),
                                            style: Get.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            "$skipped/${_questionController.questionResult.value.data?.questions?.length}",
                                            style: Get.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 40,
                                width: Get.width,
                                child: ElevatedButton(
                                  child: Text(
                                    TranslationHelper.tr("Show Results"),
                                    style: Get.textTheme.titleSmall
                                        ?.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {
                                    Get.to(() => QuizResultScreen());
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Container(
                                height: 40,
                                width: Get.width,
                                child: ElevatedButton(
                                  child: Text(
                                    TranslationHelper.tr("View Answers"),
                                    style: Get.textTheme.titleSmall
                                        ?.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {
                                    // Get student answers from question controller
                                    List<Map<String, dynamic>> studentAnswers =
                                        _questionController
                                            .calculateStudentAnswers();

                                    // Get the quiz from question controller
                                    final quiz = _questionController.quiz.value;

                                    // Navigate to answers view
                                    Get.to(() => QuizAnswersView(
                                          quiz: quiz,
                                          studentAnswers: studentAnswers,
                                        ));
                                  },
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isNavigating ? null : _handleBackToCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isNavigating
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Back to Course',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
