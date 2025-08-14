import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:

import 'package:get/get.dart';
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';

import 'package:octo_image/octo_image.dart';

Widget questionAnswerWidget(
    QuizController controller, DashboardController dashboardController) {
  return ExtendedVisibilityDetector(
    uniqueKey: const Key('Tab3'),
    child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.quizDetails.value.comments?.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (controller.quizDetails.value.comments?[index].user
                                          ?.image ==
                                      null ||
                                  controller.quizDetails.value.comments?[index]
                                          .user?.image ==
                                      "")
                              ? ClipOval(
                                  child: Image.asset(
                                    'images/profile.jpg',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipOval(
                                  child: OctoImage(
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                    image: controller.quizDetails.value
                                                .comments?[index].user?.image
                                                ?.contains('public/') ??
                                            false
                                        ? NetworkImage(
                                            "${controller.quizDetails.value.comments?[index].user?.image}")
                                        : NetworkImage(
                                            controller
                                                    .quizDetails
                                                    .value
                                                    .comments?[index]
                                                    .user
                                                    ?.image ??
                                                '',
                                          ),
                                    // placeholderBuilder: OctoPlaceholder.blurHash(
                                    //   'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                    // ),

                                    placeholderBuilder: OctoPlaceholder
                                        .circularProgressIndicator(),
                                  ),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        controller.quizDetails.value
                                                .comments?[index].user?.name
                                                .toString() ??
                                            '',
                                        style: Get.textTheme.titleMedium,
                                      ),
                                      Expanded(child: Container()),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          controller.quizDetails.value
                                                  .comments?[index].commentDate
                                                  .toString() ??
                                              '',
                                          style: Get.textTheme.titleSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    controller.quizDetails.value
                                            .comments?[index].comment
                                            .toString() ??
                                        '',
                                    style: Get.textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
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
  );
}
