import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Model/Quiz/Quiz.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:octo_image/octo_image.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class QuizAnswersView extends StatefulWidget {
  final Quiz quiz;
  final List<Map<String, dynamic>> studentAnswers;

  QuizAnswersView({
    required this.quiz,
    required this.studentAnswers,
  });

  @override
  _QuizAnswersViewState createState() => _QuizAnswersViewState();
}

class _QuizAnswersViewState extends State<QuizAnswersView> {
  QuestionController _questionController = Get.find<QuestionController>();

  bool _isNavigating = false;

  void _handleBackToCourse() async {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
    });

    // Reset HomeController state before navigating
    final homeController = Get.find<HomeController>();
    homeController.resetCourseDetails();

    final courseId = widget.quiz.courseId ?? widget.quiz.id;
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
            centerTitle: true,
            elevation: 0,
            title: Text(
              TranslationHelper.tr("Quiz Answers"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_sharp),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: widget.quiz.assign?.length ?? 0,
          itemBuilder: (context, index) {
            final question = widget.quiz.assign![index];
            final studentAnswer = widget.studentAnswers.firstWhere(
              (answer) => answer['assign_id'] == question.id,
              orElse: () => {'ans': [], 'is_correct': false},
            );

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number and text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show image (if exists) above the question text
                              if (question.questionBank?.image != null &&
                                  question.questionBank?.image != "")
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: OctoImage(
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    image: NetworkImage(
                                      question.questionBank!.image!
                                              .startsWith('http')
                                          ? question.questionBank!.image!
                                          : rootUrl +
                                              '/' +
                                              question.questionBank!.image!,
                                    ),
                                    placeholderBuilder: OctoPlaceholder
                                        .circularProgressIndicator(),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            SizedBox.shrink(),
                                  ),
                                ),
                              // Show question text without HTML tags
                              Text(
                                html_parser
                                        .parse(
                                            question.questionBank?.question ??
                                                '')
                                        .body
                                        ?.text ??
                                    '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (question.questionBank?.question == null ||
                                  question.questionBank!.question!.isEmpty)
                                Text(
                                  '${TranslationHelper.tr("Debug")}: ${TranslationHelper.tr("Question text is empty or null")}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Answer options
                    if (question.questionBank?.questionMu != null)
                      ...question.questionBank!.questionMu!.map((option) {
                        final isSelected = (studentAnswer['ans'] as List)
                            .contains(option.id.toString());
                        final isCorrect = option.status == 1;
                        final isStudentAnswer = isSelected;
                        final isStudentAnswerCorrect = isSelected && isCorrect;
                        final isStudentAnswerWrong = isSelected && !isCorrect;

                        Color optionColor = Colors.grey.shade200;
                        Color textColor = Colors.black;
                        IconData? iconData;
                        Color iconColor = Colors.transparent;
                        String? statusText;

                        if (isStudentAnswerCorrect) {
                          // Student chose the correct answer
                          optionColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                          iconData = Icons.check_circle;
                          iconColor = Colors.green;
                          statusText = TranslationHelper.tr("TRUE");
                        } else if (isStudentAnswerWrong) {
                          // Student chose the wrong answer
                          optionColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                          iconData = Icons.cancel;
                          iconColor = Colors.red;
                          statusText = TranslationHelper.tr("FALSE");
                        } else if (isCorrect) {
                          // This is the correct answer but student didn't choose it
                          optionColor = Colors.green.shade50;
                          textColor = Colors.green.shade700;
                          iconData = Icons.check_circle;
                          iconColor = Colors.green;
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: optionColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: iconColor == Colors.transparent
                                  ? Colors.grey.shade300
                                  : iconColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (iconData != null)
                                Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 20,
                                ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.title ?? '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (statusText != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusText == "TRUE"
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    statusText!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),

                    SizedBox(height: 12),

                    // Result indicator
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: studentAnswer['is_correct'] == true
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            studentAnswer['is_correct'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: studentAnswer['is_correct'] == true
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            studentAnswer['is_correct'] == true
                                ? TranslationHelper.tr("Correct")
                                : TranslationHelper.tr("Incorrect"),
                            style: TextStyle(
                              color: studentAnswer['is_correct'] == true
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Add Back to Course button at the bottom
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
