// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:

import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/start_quiz_page/widgets/question_card.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/start_quiz_page/widgets/question_selector_widget.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/start_quiz_page/widgets/timer_widget.dart';
import 'package:untitled2/utils/translation_helper.dart';

import '../../../../utils/custom_dialog.dart';

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

class StartQuizPage extends StatefulWidget {
  final CourseMain? getQuizDetails;

  StartQuizPage({this.getQuizDetails});

  @override
  _StartQuizPageState createState() => _StartQuizPageState();
}

class _StartQuizPageState extends State<StartQuizPage>
    with WidgetsBindingObserver {
  QuestionController _questionController = Get.put(QuestionController());

  int appInBackground = 0;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    // Get.delete<QuestionController>();
    // _questionController = Get.put(QuestionController());
    _questionController.startController(widget.getQuizDetails?.quiz);
    loadin();
  }

  @override
  void dispose() {
    Get.delete<QuestionController>();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showQuizEndDialog(BuildContext ctx) {
    showDialog(
        context: context,
        builder: (ctx) {
          return CustomAlertDialog(
            titleText: TranslationHelper.tr('Do you want to leave the Quiz?'),
            onTapYes: () async {
              Navigator.of(ctx).pop();
              final _questionController = Get.find<QuestionController>();

              await _questionController.finalSubmit();
            },
            onTapNo: () {
              Navigator.of(ctx).pop();
            },
          );
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (mounted) {
      final _questionController = Get.find<QuestionController>();

      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) return;

      final isBackground = state == AppLifecycleState.paused;
      if (isBackground) {
        appInBackground++;
      }

      final isResumed = state == AppLifecycleState.resumed;

      final timeCounts =
          _questionController.quiz.value.losingFocusAcceptanceNumber ?? 5;

      if (isResumed) {
        if (appInBackground >= timeCounts) {
          await _questionController.finalSubmit();
        }

        showDialog(
            context: context,
            builder: (ctx) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(ctx);
              });
              return CustomAlertDialog(
                titleText: TranslationHelper.tr('Warning'),
                color: Colors.red,
                content: Text(
                  "${TranslationHelper.tr('You have been out of Quiz')} $appInBackground ${TranslationHelper.tr('times')} ${appInBackground >= timeCounts ? ", ${TranslationHelper.tr('Your answer has been submitted')}." : ""}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showQuizEndDialog(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(Get.width, 100),
            child: AppBar(
              backgroundColor: Color(0xff18294d),
              centerTitle: false,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    alignment: Alignment.centerLeft,
                    width: 80,
                    height: 30,
                    child: Image.asset(
                      'images/$appLogo',
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: Text(TranslationHelper.tr(
                                          'Do you want to leave the Quiz?')),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child:
                                              Text(TranslationHelper.tr('No')),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child:
                                              Text(TranslationHelper.tr('Yes')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmed == true) {
                                  await _questionController.finalSubmit();
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _getQuizTitle(
                                        _questionController.quiz.value.title) ??
                                    "Quiz",
                                style: context.textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: loading
              ? Center(child: CircularProgressIndicator())
              : Obx(() {
                  if (_questionController.quizResultLoading.value) {
                    return Stack(
                      children: [
                        Container(
                          color: Color(0xff18294d),
                          width: Get.width,
                          height: Get.height,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(child: CircularProgressIndicator()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              TranslationHelper.tr(
                                  "Quiz Result Processing. Please wait"),
                              style: Get.textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Color(0xff18294d),
                        width: Get.width,
                        height: Get.height,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text.rich(
                                    TextSpan(
                                      text:
                                          "${TranslationHelper.tr("Question")} ${_questionController.questionNumber.value}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text:
                                              "/${_questionController.quiz.value.assign?.length}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TimerWidget(),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0),
                          QuestionSelectorWidget(),
                          SizedBox(height: 10.0),
                          Expanded(
                            child: PageView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _questionController.pageController,
                              onPageChanged: _questionController.updateTheQnNum,
                              itemCount: _questionController.questions.length,
                              itemBuilder: (context, index) {
                                return QuestionCard(
                                  assign: _questionController.questions[index],
                                  index: index,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
        ),
      ),
    );
  }

  bool loading = true;

  void loadin() async {
    await 2000.milliseconds.delay();
    setState(() {
      loading = false;
    });
  }
}
