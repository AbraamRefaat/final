// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';

// Project imports:

import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Model/Quiz/QuestionResultModel.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class QuizResultScreen extends StatefulWidget {
  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final QuestionController _questionController = Get.put(QuestionController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: AppBarWidget(
            showSearch: false,
            goToSearch: false,
            showBack: true,
            showFilterBtn: false,
          ),
          body: Obx(() {
            if (_questionController.quizResultLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: Get.theme.primaryColor,
                ),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 15),
                children: [
                  SizedBox(height: 10),
                  _questionController.questionResult.value.data?.duration !=
                          null
                      ? Text(
                          "${TranslationHelper.tr("Time taken")}"
                                  ": ${_questionController.getTimeStringFromDouble(double.parse(_questionController.questionResult.value.data?.duration ?? ''))} " +
                              TranslationHelper.tr("minute(s)"),
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      itemCount: _questionController
                              .questionResult.value.data?.questions?.length ??
                          0,
                      itemBuilder: (context, index) {
                        Question question = _questionController
                                .questionResult.value.data?.questions?[index] ??
                            Question();
                        if (question.type == "S" || question.type == "L") {
                          return ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}) ",
                                    style: Get.textTheme.titleMedium,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 2),
                                      child: HtmlWidget(
                                        '''${question.qus ?? "_"}''',
                                        textStyle: Get.textTheme.titleSmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    "${TranslationHelper.tr("Answer")}" + ": ",
                                    style: Get.textTheme.titleMedium,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 2),
                                    child: HtmlWidget(
                                      '''${question.answer ?? "_"}''',
                                      textStyle: Get.textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}) ",
                                    style: Get.textTheme.titleMedium,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 2),
                                      child: HtmlWidget(
                                        '''${question.qus ?? "_"}''',
                                        textStyle: Get.textTheme.titleSmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: question.option?.length ?? 0,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, optionIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              question.option?[optionIndex]
                                                          .right ==
                                                      true
                                                  ? Icon(
                                                      Icons.check_circle_sharp,
                                                      color: Color(0xff6FDC43),
                                                    )
                                                  : question
                                                              .option?[
                                                                  optionIndex]
                                                              .wrong ==
                                                          true
                                                      ? Icon(
                                                          Icons.cancel_rounded,
                                                          color:
                                                              Color(0xffFF1414),
                                                        )
                                                      : Icon(
                                                          Icons.circle_outlined,
                                                          color:
                                                              Color(0xffE9E7F7),
                                                        ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "${question.option?[optionIndex].title}",
                                                  style:
                                                      Get.textTheme.titleMedium,
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                  question.isSubmit == false
                                      ? Container()
                                      : question.isWrong == false
                                          ? Image.asset(
                                              'images/quiz_correct.png',
                                              height: 50,
                                              width: 50,
                                            )
                                          : Image.asset(
                                              'images/quiz_wrong.png',
                                              height: 50,
                                              width: 50,
                                            ),
                                ],
                              ),
                            ],
                          );
                        }
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  // Add Back to Course button below View Answers
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Reset HomeController state before navigating
                        final homeController = Get.find<HomeController>();
                        homeController.resetCourseDetails();
                        // Pass courseId to MainNavigationPage for correct navigation and back behavior
                        final courseId =
                            _questionController.quiz.value.courseId ??
                                _questionController.quiz.value.id;
                        if (courseId != null) {
                          await Get.offUntil(
                            MaterialPageRoute(
                                builder: (_) => MainNavigationPage(),
                                settings: RouteSettings(
                                    arguments: {'goToCourseId': courseId})),
                            (route) => false,
                          );
                        } else {
                          await Get.offUntil(
                            MaterialPageRoute(
                                builder: (_) => MainNavigationPage()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Back to Course',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            }
          })),
    );
  }
}
