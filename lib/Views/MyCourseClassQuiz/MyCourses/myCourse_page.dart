// Flutter imports:
// Package imports:
import 'dart:developer';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/NewControllerAndModels/models/my_course_model.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/styles.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:octo_image/octo_image.dart';

import 'my_course_details_view/my_course_details_view.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Views/Account/sign_in_page.dart';

class MyCoursePage extends StatelessWidget {
  final MyCourseController controller = Get.put(MyCourseController());

  MyCoursePage({Key? key}) : super(key: key);

  Future<void> refresh() async {
    controller.myCourses.value = [];
    controller.fetchMyCourse();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double percentageWidth = width / 100;
    double height = MediaQuery.of(context).size.height;
    double percentageHeight = height / 100;
    return ExtendedVisibilityDetector(
      uniqueKey: const Key('MyCourseKey'),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.only(left: 20, bottom: 14.72, right: 20),
                child: Texth1(TranslationHelper.tr("Courses")),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 20,
                  bottom: 50.72,
                  right: 20,
                  top: 10,
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CupertinoActivityIndicator());
                  } else {
                    if (controller.myCourses.length == 0) {
                      return Center(
                        child: Container(
                          child: Texth1(
                            TranslationHelper.tr("No Course found"),
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: 200,
                      ),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: controller.myCourses.length,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Get.theme.cardColor,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Get.theme.shadowColor,
                                  blurRadius: 10.0,
                                  offset: Offset(2, 3),
                                ),
                              ],
                            ),
                            width: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    child: Container(
                                      width: Get.width,
                                      height: 100,
                                      child: (controller
                                                      .myCourses[index].image !=
                                                  null &&
                                              controller.myCourses[index].image!
                                                  .isNotEmpty &&
                                              controller
                                                      .myCourses[index].image !=
                                                  "")
                                          ? OctoImage(
                                              image: NetworkImage(
                                                "${controller.myCourses[index].image}",
                                              ),
                                              placeholderBuilder: OctoPlaceholder
                                                  .circularProgressIndicator(),
                                              fit: BoxFit.contain,
                                              errorBuilder: (
                                                BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace,
                                              ) {
                                                // If image fails to load, show no image placeholder
                                                return Container(
                                                  color: Get.theme.cardColor,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color:
                                                          Get.theme.hintColor,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Get.theme.cardColor,
                                              child: Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Get.theme.hintColor,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 12,
                                    right: 30,
                                    top: 10,
                                    bottom: 15,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      courseTitle(
                                        controller.myCourses[index].title ?? "",
                                      ),
                                      courseTPublisher(
                                        controller.myCourses[index]
                                                .assignedInstructor ??
                                            '',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            context.loaderOverlay.show();
                            controller.courseID.value =
                                controller.myCourses[index].id;
                            controller.selectedLessonID.value = 0;
                            controller.myCourseDetailsTabController.controller
                                ?.index = 0;
                            controller.totalCourseProgress.value = controller
                                .myCourses[index].totalCompletePercentage;
                            await controller.getCourseDetails();
                            Get.to(() => MyCourseDetailsView());
                            context.loaderOverlay.hide();
                          },
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
