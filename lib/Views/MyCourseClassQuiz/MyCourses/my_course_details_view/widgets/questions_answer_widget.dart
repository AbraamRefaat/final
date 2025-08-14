import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:octo_image/octo_image.dart';
import 'dart:math' as math;
import 'package:untitled2/utils/translation_helper.dart';

Widget questionsAnswerWidget(
    MyCourseController controller, double percentageWidth) {
  return ExtendedVisibilityDetector(
    uniqueKey: const Key('Tab3'),
    child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.myCourseDetails.value.comments?.length ?? 0,
              physics: NeverScrollableScrollPhysics(),
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
                          ClipOval(
                            child: (controller.myCourseDetails.value
                                            .comments![index].user!.image ==
                                        null ||
                                    controller.myCourseDetails.value
                                            .comments![index].user!.image ==
                                        "")
                                ? Image.asset(
                                    'images/profile.jpg',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  )
                                : OctoImage(
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                    image: controller.myCourseDetails.value
                                                .comments![index].user!.image
                                                ?.contains('public/') ??
                                            false
                                        ? NetworkImage(
                                            '${controller.myCourseDetails.value.comments?[index].user?.image}')
                                        : NetworkImage(controller
                                                .myCourseDetails
                                                .value
                                                .comments?[index]
                                                .user
                                                ?.image ??
                                            ''),
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
                                        controller.myCourseDetails.value
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
                                          controller.myCourseDetails.value
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
                                    controller.myCourseDetails.value
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              child: ClipOval(
                child: stctrl.dashboardController.profileData.image == null ||
                        stctrl.dashboardController.profileData.image == ''
                    ? Image.asset('images/profile.jpg')
                    : OctoImage(
                        fit: BoxFit.cover,
                        height: 40,
                        width: 40,
                        image: stctrl.dashboardController.profileData.image!
                                .contains('public/')
                            ? NetworkImage(
                                "${stctrl.dashboardController.profileData.image}")
                            : NetworkImage(
                                "${stctrl.dashboardController.profileData.image}"),
                        // placeholderBuilder:
                        //     OctoPlaceholder.blurHash(
                        //   'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                        // ),
                        placeholderBuilder:
                            OctoPlaceholder.circularProgressIndicator(),
                      ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                width: percentageWidth * 50,
                constraints: BoxConstraints(maxHeight: percentageWidth * 15),
                decoration: BoxDecoration(
                  color: Color(0xffF2F6FF),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.zero,
                child: TextField(
                  controller: controller.commentController,
                  maxLines: 10,
                  minLines: 1,
                  autofocus: false,
                  showCursor: true,
                  scrollPhysics: AlwaysScrollableScrollPhysics(),
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      filled: true,
                      fillColor: Get.theme.canvasColor,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(142, 153, 183, 0.4),
                            width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(142, 153, 183, 0.4),
                            width: 1.0),
                      ),
                      hintText: TranslationHelper.tr("Add Comment"),
                      hintStyle: Get.textTheme.titleMedium),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                if (controller.commentController.value.text.trim() == '') {
                  return;
                }
                controller.submitComment(controller.myCourseDetails.value.id,
                    controller.commentController.value.text);
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    color: Get.theme.primaryColor, shape: BoxShape.circle),
                child: Obx(() => Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: controller.commentLoader.value == true
                          ? CircularProgressIndicator(color: Colors.black)
                          : Transform.rotate(
                              angle: math.pi / 4,
                              child: Icon(
                                FontAwesomeIcons.locationArrow,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                    )),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    ),
  );
}
