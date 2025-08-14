import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';

import 'package:untitled2/utils/CustomAlertBox.dart';

import 'package:untitled2/utils/CustomText.dart';

import 'package:untitled2/utils/widgets/StarCounterWidget.dart';
import 'package:untitled2/utils/translation_helper.dart';

import 'package:octo_image/octo_image.dart';

Widget reviewWidget(
    {required HomeController controller,
    required DashboardController dashboardController,
    required double percentageHeight,
    required double percentageWidth,
    required GetStorage userToken,
    required String tokenKey}) {
  return ExtendedVisibilityDetector(
      uniqueKey: const Key('Tab4'),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          SizedBox(height: 10),
          GestureDetector(
            child: Container(
              width: percentageWidth * 100,
              height: percentageHeight * 6,
              padding: EdgeInsets.fromLTRB(20, 0, 30, 0),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(23),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cartTotal("${TranslationHelper.tr("Rate the course")}"),
                  Icon(
                    Icons.add,
                    color: Get.theme.primaryColor,
                    size: 15,
                  )
                ],
              ),
            ),
            onTap: () {
              var myRating = 5.0;
              controller.reviewText.clear();
              userToken.read(tokenKey) != null
                  ? Get.bottomSheet(SingleChildScrollView(
                      child: Container(
                        width: percentageWidth * 100,
                        height: percentageHeight * 54.68,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                            decoration: BoxDecoration(
                              color: Get.theme.cardColor,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(30),
                                  topRight: const Radius.circular(30)),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      width: percentageWidth * 18.66,
                                      height: percentageHeight * 1,
                                      decoration: BoxDecoration(
                                          color: Color(0xffE5E5E5),
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(4.5)),
                                      // color: Color(0xffE5E5E5),
                                    ),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Center(
                                    child: Text(
                                      "${TranslationHelper.tr("Rate the course")}",
                                      style: Get.textTheme.titleMedium
                                          ?.copyWith(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Center(
                                    child: Text(
                                      "${TranslationHelper.tr("Your rating")}",
                                      style: Get.textTheme.titleSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: RatingBar.builder(
                                      itemSize: 30,
                                      initialRating: myRating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 1.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        myRating = rating;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: percentageWidth * 100,
                                    height: percentageHeight * 12.19,
                                    decoration: BoxDecoration(
                                      color: Get.theme.cardColor,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            height: percentageHeight * 6.19,
                                            width: percentageWidth * 12,
                                            child: ClipOval(
                                              child: OctoImage(
                                                fit: BoxFit.cover,
                                                height: 40,
                                                width: 40,
                                                image: dashboardController
                                                        .profileData.image!
                                                        .contains('public/')
                                                    ? NetworkImage(
                                                        "${dashboardController.profileData.image ?? ""}")
                                                    : NetworkImage(
                                                        dashboardController
                                                                .profileData
                                                                .image ??
                                                            ""),
                                                // placeholderBuilder:
                                                //     OctoPlaceholder.blurHash(
                                                //   'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                                // ),
                                                placeholderBuilder: OctoPlaceholder
                                                    .circularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: percentageWidth * 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: percentageHeight * 12.19,
                                            width: percentageWidth * 75.22,
                                            decoration: BoxDecoration(
                                              color: Color(0xffF2F6FF),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              maxLines: 6,
                                              controller: controller.reviewText,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                  left: 10,
                                                  top: 10,
                                                ),
                                                filled: true,
                                                fillColor:
                                                    Get.theme.canvasColor,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          142, 153, 183, 0.4),
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          142, 153, 183, 0.4),
                                                      width: 1.0),
                                                ),
                                                hintText:
                                                    "${TranslationHelper.tr("Your Review")}",
                                                hintStyle:
                                                    Get.textTheme.titleSmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.submitCourseReview(
                                          controller.courseDetails.value.id,
                                          controller.reviewText.value.text,
                                          myRating);
                                    },
                                    child: Container(
                                      width: percentageWidth * 50,
                                      height: percentageHeight * 5,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Get.theme.primaryColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        "${TranslationHelper.tr("Submit Review")}",
                                        style:
                                            Get.textTheme.titleSmall?.copyWith(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ])),
                      ),
                    ))
                  : showLoginAlertDialog(
                      "${TranslationHelper.tr("Login")}",
                      "${TranslationHelper.tr("You are not Logged In")}",
                      "${TranslationHelper.tr("Login")}");
              Container();
            },
          ),
          controller.courseDetails.value.reviews?.length == 0
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    "${TranslationHelper.tr("No Review Found")}",
                    style: Get.textTheme.titleSmall,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.courseDetails.value.reviews?.length,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: percentageWidth * 100,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controller.courseDetails.value.reviews![index]
                                      .userImage!
                                      .contains('public/')
                                  ? CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Color(0xFFD7598F),
                                      backgroundImage: NetworkImage(
                                          "${controller.courseDetails.value.reviews?[index].userImage}"))
                                  : CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Color(0xFFD7598F),
                                      backgroundImage: NetworkImage(
                                        controller.courseDetails.value
                                                .reviews?[index].userImage ??
                                            '',
                                      )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          cartTotal(controller
                                                  .courseDetails
                                                  .value
                                                  .reviews?[index]
                                                  .userName ??
                                              ''),
                                          Expanded(
                                            child: Container(),
                                          ),
                                          StarCounterWidget(
                                            value: controller.courseDetails
                                                .value.reviews![index].star!
                                                .toDouble(),
                                            color: Color(0xffFFCF23),
                                            size: 10,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 0),
                                        child: courseStructure(controller
                                                .courseDetails
                                                .value
                                                .reviews?[index]
                                                .comment ??
                                            ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
        ],
      ));
}
