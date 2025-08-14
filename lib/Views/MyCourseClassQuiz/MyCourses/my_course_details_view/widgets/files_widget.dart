import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/download_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Course/FileElement.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/widgets/files_details_widget.dart';

Widget filesWidget(MyCourseController controller) {
  final DownloadController downloadController = Get.put(DownloadController());

  return ExtendedVisibilityDetector(
    uniqueKey: const Key('Tab2'),
    child: ListView.builder(
      itemCount: controller.myCourseDetails.value.files?.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return fileDetailsWidget(
            context,
            controller.myCourseDetails.value.files?[index] ?? FileElement(),
            downloadController);
      },
    ),
  );
}
