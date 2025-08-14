import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Model/Quiz/Assign.dart';
import 'package:untitled2/Model/Quiz/QuestionMu.dart';
import 'package:untitled2/utils/translation_helper.dart';

class ContinueSkipSubmitBtn extends StatelessWidget {
  ContinueSkipSubmitBtn({
    this.qnController,
    this.index,
    this.data,
    this.showEachSubmit,
    this.correctAnswer,
    this.formKey,
    this.type,
    this.checkBoxList,
    this.assign,
  });

  final QuestionController? qnController;
  final int? index;
  final Map? data;
  final bool? showEachSubmit;
  final List<QuestionMu>? correctAnswer;
  final GlobalKey<FormState>? formKey;
  final String? type;
  final List<CheckboxModal>? checkBoxList;
  final Assign? assign;

  @override
  Widget build(BuildContext context) {
    if (qnController!.submitSingleAnswer.value) {
      return Center(
        child: CircularProgressIndicator(
          color: Get.theme.primaryColor,
        ),
      );
    } else if (qnController!.lastQuestion.value) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            if ((type == 'S' || type == 'L') && formKey != null) {
              if (formKey!.currentState!.validate()) {
                await qnController
                    ?.singleSubmit(data ?? Map(), index ?? 0)
                    .then((value) {
                  if (value) {
                    qnController?.skipPress(index);
                  } else {
                    Get.snackbar(
                      TranslationHelper.tr("Error"),
                      TranslationHelper.tr("Error submitting answer"),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[700],
                      colorText: Colors.black,
                      borderRadius: 5,
                      duration: Duration(seconds: 3),
                    );
                  }
                });
              }
            } else {
              if (data?['ans'].length == 0) {
                // Please select an option
              } else {
                await qnController
                    ?.singleSubmit(data ?? Map(), index ?? 0)
                    .then((value) {
                  if (value) {
                    qnController?.skipPress(index);
                  } else {
                    Get.snackbar(
                      TranslationHelper.tr("Error"),
                      TranslationHelper.tr("Error submitting answer"),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[700],
                      colorText: Colors.black,
                      borderRadius: 5,
                      duration: Duration(seconds: 3),
                    );
                  }
                });
              }
            }
          },
          child: Text(
            TranslationHelper.tr("Submit"),
            style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            if ((type == 'S' || type == 'L') && formKey != null) {
              if (formKey!.currentState!.validate()) {
                await qnController
                    ?.singleSubmit(data ?? Map(), index ?? 0)
                    .then((value) {
                  if (value) {
                    qnController?.skipPress(index);
                  } else {
                    Get.snackbar(
                      TranslationHelper.tr("Error"),
                      TranslationHelper.tr("Error submitting answer"),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[700],
                      colorText: Colors.black,
                      borderRadius: 5,
                      duration: Duration(seconds: 3),
                    );
                  }
                });
              }
            } else {
              if (data?['ans'].length == 0) {
                // Please select an option
              } else {
                await qnController
                    ?.singleSubmit(data ?? Map(), index ?? 0)
                    .then((value) {
                  if (value) {
                    qnController?.skipPress(index);
                  } else {
                    Get.snackbar(
                      TranslationHelper.tr("Error"),
                      TranslationHelper.tr("Error submitting answer"),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[700],
                      colorText: Colors.black,
                      borderRadius: 5,
                      duration: Duration(seconds: 3),
                    );
                  }
                });
              }
            }
          },
          child: Text(
            TranslationHelper.tr("Continue"),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}
