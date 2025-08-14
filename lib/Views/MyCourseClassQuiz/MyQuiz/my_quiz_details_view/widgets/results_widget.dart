import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Model/Quiz/MyQuizResultsModel.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/quiz_result_screen.dart';
import 'package:untitled2/utils/CustomDate.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/translation_helper.dart';

Widget resultsWidget(
    {required QuizController controller,
    required DashboardController dashboardController}) {
  // return Container();
  return ExtendedVisibilityDetector(
    uniqueKey: const Key('Tab3'),
    child: Container(
      child: controller.myQuizResult.value.data?.length == 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Texth1(TranslationHelper.tr("no results found")),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          TranslationHelper.tr("Date"),
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          TranslationHelper.tr("Mark"),
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "%",
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          TranslationHelper.tr("Rating"),
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount:
                          controller.myQuizResult.value.data?.length ?? 0,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 16,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final MyQuizResultsData data =
                            controller.myQuizResult.value.data?[index] ??
                                MyQuizResultsData();
                        var obtainedMarks = 0;
                        var totalScore = 0;
                        var status = "";
                        var percentage = "";
                        data.result?.forEach((element) {
                          if (element.quizTestId == data.id) {
                            obtainedMarks = element.score;
                            totalScore = element.totalScore;
                            if (element.publish == 1) {
                              status = element.status ?? '';
                            } else {
                              status = "Pending";
                            }
                            percentage = double.parse(
                                    ((element.score / element.totalScore) * 100)
                                        .toString())
                                .toStringAsFixed(2);
                          }
                        });
                        return InkWell(
                          onTap: () async {
                            final QuestionController questionController =
                                Get.put(QuestionController());

                            await questionController
                                .getQuizResultPreview(data.id);
                            Get.to(() => QuizResultScreen());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${CustomDate().formattedDate(data.startAt)}",
                                  textAlign: TextAlign.start,
                                  style: context.textTheme.titleMedium,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  " $obtainedMarks/$totalScore",
                                  style: context.textTheme.titleSmall,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "$percentage %",
                                  style: context.textTheme.titleSmall,
                                ),
                              ),
                              status == "Pending"
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xfff4f6fe),
                                          borderRadius:
                                              BorderRadius.circular(3)),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "$status".toUpperCase(),
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    )
                                  : status == "Failed"
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xffFF1414),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "$status",
                                            style: context.textTheme.titleSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "$status",
                                            style: context.textTheme.titleSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.015,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
    ),
  );
}
