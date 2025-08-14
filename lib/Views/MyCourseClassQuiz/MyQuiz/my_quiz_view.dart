// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:

import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/NewControllerAndModels/models/my_quiz_model.dart';
import 'package:untitled2/utils/widgets/SingleCardItemWidget.dart';
import 'my_quiz_details_view/my_quiz_details_view.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/translation_helper.dart';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

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

class MyQuizView extends StatefulWidget {
  const MyQuizView({Key? key}) : super(key: key);

  @override
  _MyQuizViewState createState() => _MyQuizViewState();
}

class _MyQuizViewState extends State<MyQuizView> {
  double width = 0;
  double percentageWidth = 0;
  double height = 0;
  double percentageHeight = 0;

  final QuizController myQuizController =
      Get.find<QuizController>(); // Use find instead of put

  var allMyQuizSearch = <MyQuizModel>[].obs;

  var quizSearchStarted = false.obs;

  onSearchTextChanged(String text) async {
    quizSearchStarted.value = true;
    allMyQuizSearch.clear();
    if (text.isEmpty) {
      quizSearchStarted.value = false;
      return;
    }

    myQuizController.allMyQuiz.forEach((value) {
      if ((value.title ?? "")
              .toUpperCase()
              .contains(text.toUpperCase()) || // search  with course title name
          (value.assignedInstructor ?? "")
              .toUpperCase()
              .contains(text.toUpperCase())) {
        allMyQuizSearch.add(value);
      }
    });
  }

  Future<void> refresh() async {
    myQuizController.allMyQuiz.value = [];
    myQuizController.allClassText.value = TranslationHelper.tr("My Quiz");
    myQuizController.courseFiltered.value = false;
    myQuizController.fetchAllMyQuiz();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;
    myQuizController.allClassText.value = TranslationHelper.tr("My Quiz");
    return ExtendedVisibilityDetector(
        uniqueKey: const Key('MyClassKey'),
        child: SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                      left: 20,
                      bottom: 14.72,
                      right: 20,
                    ),
                    child: Texth1(myQuizController.allClassText.value),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                        left: 20,
                        bottom: 50.72,
                        right: 20,
                        top: 10,
                      ),
                      child: Obx(() {
                        if (myQuizController.isLoading.value)
                          return Center(
                            child: CupertinoActivityIndicator(),
                          );
                        else {
                          if (myQuizController.allMyQuiz.length == 0) {
                            return Container(
                              child: Center(
                                  child: Texth1(
                                      TranslationHelper.tr("No Quiz found"))),
                            );
                          }
                          if (!quizSearchStarted.value) {
                            return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  mainAxisExtent: 200,
                                ),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                itemCount: myQuizController.allMyQuiz.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return SingleItemCardWidget(
                                    showPricing: false,
                                    image:
                                        "${myQuizController.allMyQuiz[index].image}",
                                    title: _getQuizTitle(myQuizController
                                            .allMyQuiz[index].title) ??
                                        "Quiz",
                                    subTitle: myQuizController.allMyQuiz[index]
                                            .assignedInstructor ??
                                        '',
                                    price:
                                        myQuizController.allMyQuiz[index].price,
                                    discountPrice: myQuizController
                                        .allMyQuiz[index].discountPrice,
                                    onTap: () async {
                                      myQuizController.courseID.value =
                                          myQuizController.allMyQuiz[index].id;
                                      myQuizController.getMyQuizDetails();
                                      Get.to(() => MyQuizDetailsPageView());
                                    },
                                  );
                                });
                          }
                          return allMyQuizSearch.length == 0
                              ? Text(
                                  TranslationHelper.tr("No Quiz found"),
                                  style: Get.textTheme.titleMedium,
                                )
                              : Container(
                                  child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                        mainAxisExtent: 200,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      itemCount: allMyQuizSearch.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SingleItemCardWidget(
                                          showPricing: false,
                                          image:
                                              "${allMyQuizSearch[index].image}",
                                          title: _getQuizTitle(
                                                  allMyQuizSearch[index]
                                                      .title) ??
                                              '',
                                          subTitle: allMyQuizSearch[index]
                                                  .assignedInstructor ??
                                              '',
                                          price: allMyQuizSearch[index].price,
                                          discountPrice: allMyQuizSearch[index]
                                              .discountPrice,
                                          onTap: () async {
                                            myQuizController.courseID.value =
                                                allMyQuizSearch[index].id;
                                            myQuizController.getMyQuizDetails();
                                            Get.to(
                                                () => MyQuizDetailsPageView());
                                          },
                                        );
                                      }),
                                );
                        }
                      })),
                ],
              ),
            ),
          ),
        ));
  }
}
