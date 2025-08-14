import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/utils/translation_helper.dart';

class TimerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestionController>(
      // init: QuestionController(),
      builder: (controller) {
        Duration clockTimer =
            Duration(seconds: controller.animation?.value ?? 1);
        String remainingTime =
            '${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("$remainingTime" + " " + TranslationHelper.tr("minute(s)")),
            controller.quiz.value.questionTimeType == 1
                ? Text(TranslationHelper.tr("Left for the quiz"))
                : Text(TranslationHelper.tr("Left for this section")),
          ],
        );
      },
    );
  }
}
