import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:untitled2/Controller/question_controller.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF3F4768), width: 3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: GetBuilder<QuestionController>(
        // init: QuestionController(),
        builder: (controller) {
          Duration clockTimer = Duration(seconds: controller.animation?.value);
          Duration clockTimer2 =
              Duration(seconds: controller.questionTime.value * 60);
          String remainingTime =
              '${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
          String totalTime =
              '${clockTimer2.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer2.inSeconds.remainder(60).toString().padLeft(2, '0')}';
          return Stack(
            fit: StackFit.loose,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: controller.animation?.value.toDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF46A0AE), Color(0xFF00FFCB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0 / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$remainingTime/$totalTime"),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
