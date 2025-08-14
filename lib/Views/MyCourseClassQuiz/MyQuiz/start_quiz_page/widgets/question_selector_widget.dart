import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/question_controller.dart';

class QuestionSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestionController>(
        // init: QuestionController(),
        builder: (qnController) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView.separated(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final color = qnController.checkSelected(index)
                  ? Get.theme.primaryColor
                  : Colors.white;
              return GestureDetector(
                onTap: () {
                  qnController.questionSelect(index);
                },
                child: qnController.answered[index] == true
                    ? CircleAvatar(
                        backgroundColor: Get.theme.primaryColor,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ))
                    : CircleAvatar(
                        backgroundColor: color,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: qnController.checkSelected(index)
                                ? Colors.white
                                : Colors.black,
                            fontWeight: qnController.checkSelected(index)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                width: 5.0,
              );
            },
            itemCount: qnController.quiz.value.assign?.length ?? 0),
      );
    });
  }
}
