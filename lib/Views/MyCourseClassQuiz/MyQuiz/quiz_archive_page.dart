import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Views/Account/sign_in_page.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/quiz_result_screen.dart';
import 'package:untitled2/utils/CustomDate.dart';
import 'package:untitled2/utils/CustomText.dart';

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

/// Format date for display
String _formatDate(dynamic date) {
  if (date == null) return '';

  try {
    if (date is String) {
      DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return date.toString();
  } catch (e) {
    return date.toString();
  }
}

class QuizArchivePage extends StatelessWidget {
  const QuizArchivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final QuizController quizController =
        Get.find<QuizController>(); // Use find instead of put

    // Fetch quiz results when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (quizController.allQuizResults.isEmpty) {
        quizController.fetchAllQuizResults();
      }
    });

    return Obx(() {
      // If not logged in, show SignInPage
      if (!dashboardController.loggedIn.value) {
        return SignInPage();
      }

      // If logged in, show the quiz archive content
      return Scaffold(
        appBar: AppBarWidget(
          showSearch: false,
          goToSearch: false,
          showBack: false,
          showFilterBtn: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Refresh the quiz results data
            await quizController.fetchAllQuizResults();
          },
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  TranslationHelper.tr('Quiz Archive'),
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  TranslationHelper.tr('View your completed quiz results'),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),

                // Quiz Results List
                Expanded(
                  child: Obx(() {
                    if (quizController.isAllQuizResultsLoading.value) {
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }

                    if (quizController.allQuizResults.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 20),
                            Text(
                              TranslationHelper.tr(
                                  'No completed quizzes found'),
                              style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              TranslationHelper.tr(
                                  'Complete some quizzes to see your results here'),
                              textAlign: TextAlign.center,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: quizController.allQuizResults.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final quizResult = quizController.allQuizResults[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              // Navigate to quiz details with results
                              Get.to(() =>
                                  QuizArchiveResultsView(quiz: quizResult));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quiz Title
                                  Text(
                                    _getQuizTitle(quizResult['quiz_title'] ??
                                            quizResult['title']) ??
                                        TranslationHelper.tr('Quiz'),
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),

                                  // Instructor
                                  if (quizResult['instructor_name'] != null)
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 16, color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            quizResult['instructor_name'],
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 12),

                                  // Score and Date
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (quizResult['score'] != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${TranslationHelper.tr('Score')}: ${quizResult['score']}%',
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      Spacer(),
                                      if (quizResult['completed_at'] != null)
                                        Text(
                                          '${TranslationHelper.tr('Completed')}: ${_formatDate(quizResult['completed_at'])}',
                                          style:
                                              Get.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  // Action button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        TranslationHelper.tr('View Results'),
                                        style:
                                            Get.textTheme.bodySmall?.copyWith(
                                          color: Get.theme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Get.theme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// Quiz Archive Results View - Shows detailed results for a specific quiz
class QuizArchiveResultsView extends StatelessWidget {
  final dynamic quiz;

  const QuizArchiveResultsView({Key? key, required this.quiz})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuizController quizController = Get.find<QuizController>();

    return Scaffold(
      appBar: AppBarWidget(
        showSearch: false,
        goToSearch: false,
        showBack: true,
        showFilterBtn: false,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Title
            Text(
              _getQuizTitle(quiz['quiz_title'] ?? quiz['title']) ??
                  TranslationHelper.tr('Quiz Results'),
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Quiz Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quiz['score'] != null)
                      Row(
                        children: [
                          Icon(Icons.score, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '${TranslationHelper.tr('Score')}: ${quiz['score']}%',
                            style: Get.textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if (quiz['completed_at'] != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            '${TranslationHelper.tr('Completed')}: ${_formatDate(quiz['completed_at'])}',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                    if (quiz['instructor_name'] != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            '${TranslationHelper.tr('Instructor')}: ${quiz['instructor_name']}',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Navigate to detailed results view
                      final QuestionController questionController =
                          Get.put(QuestionController());
                      await questionController.getQuizResultPreview(quiz['id']);
                      Get.to(() => QuizResultScreen());
                    },
                    icon: Icon(Icons.assessment),
                    label: Text(TranslationHelper.tr('View Detailed Results')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
