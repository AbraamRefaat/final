import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:octo_image/octo_image.dart';
import 'package:untitled2/Controller/question_controller.dart';
import 'package:untitled2/Model/Quiz/Assign.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/start_quiz_page/widgets/continue_skip_submit_btn.dart';

class QuestionCard extends StatefulWidget {
  QuestionCard({this.assign, this.index});

  final Assign? assign;
  final int? index;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController shortAnsCtrl = TextEditingController();

  final TextEditingController longAnsCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<CheckboxModal> checkBoxList = [];
  int? selectedRadioIndex; // Track the selected answer index for single choice
  List<int> assignIds = [];

  onItemClicked(CheckboxModal ckbItem) {
    setState(() {
      ckbItem.value = !ckbItem.value!;
    });
    if (ckbItem.value!) {
      assignIds.add(ckbItem.id!);
    } else {
      assignIds.remove(ckbItem.id);
    }
  }

  onRadioSelected(int index) {
    setState(() {
      selectedRadioIndex = index;
    });
    assignIds = [checkBoxList[index].id!]; // Only one answer allowed
  }

  @override
  void initState() {
    if (widget.assign?.questionBank?.type == "M") {
      widget.assign?.questionBank?.questionMu?.forEach((element) {
        checkBoxList.add(CheckboxModal(
            title: element.title,
            id: element.id,
            value: false,
            status: element.status));
      });
      selectedRadioIndex = null;
      assignIds = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<QuestionController>(
        // init: QuestionController(),
        builder: (qnController) {
      if (widget.assign?.questionBank?.type == "M") {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          padding: EdgeInsets.all(22.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: HtmlWidget(
                      '''${widget.assign?.questionBank?.question ?? ""}''',
                      textStyle: Get.textTheme.titleSmall
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                  // Show image (if exists) immediately after question text and before choices
                  if (widget.assign?.questionBank?.image != null &&
                      widget.assign?.questionBank?.image != "")
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: OctoImage(
                        fit: BoxFit.contain,
                        width: double.infinity,
                        image: NetworkImage(
                          widget.assign!.questionBank!.image!.startsWith('http')
                              ? widget.assign!.questionBank!.image!
                              : rootUrl +
                                  '/' +
                                  widget.assign!.questionBank!.image!,
                        ),
                        placeholderBuilder:
                            OctoPlaceholder.circularProgressIndicator(),
                        errorBuilder: (context, error, stackTrace) =>
                            SizedBox.shrink(),
                      ),
                    ),
                  SizedBox(height: 10),
                  ...checkBoxList.asMap().entries.map((entry) {
                    int idx = entry.key;
                    CheckboxModal item = entry.value;
                    return ListTile(
                      onTap: () => qnController.answered[widget.index ?? 0]
                          ? qnController.quiz.value.questionReview == 1
                              ? onRadioSelected(idx)
                              : null
                          : onRadioSelected(idx),
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                        value: idx,
                        groupValue: selectedRadioIndex,
                        onChanged: (int? value) {
                          if (qnController.answered[widget.index ?? 0]) {
                            if (qnController.quiz.value.questionReview == 1) {
                              onRadioSelected(idx);
                            }
                          } else {
                            onRadioSelected(idx);
                          }
                        },
                        activeColor: Get.theme.primaryColor,
                      ),
                      trailing:
                          qnController.quiz.value.showResultEachSubmit == 1
                              ? qnController.answered[widget.index ?? 0] == true
                                  ? item.status == 1
                                      ? Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                        )
                                  : SizedBox(
                                      width: 1,
                                      height: 1,
                                    )
                              : SizedBox(
                                  width: 1,
                                  height: 1,
                                ),
                      title: Transform.translate(
                          offset: Offset(-16, 0),
                          child: Text(
                            item.title ?? '',
                            style: Get.textTheme.titleMedium
                                ?.copyWith(color: Colors.black),
                          )),
                    );
                  }).toList(),
                  // Remove the old image display after the choices (delete any OctoImage or image widget here)
                  SizedBox(height: 50),
                  ContinueSkipSubmitBtn(
                    qnController: qnController,
                    index: widget.index ?? 0,
                    showEachSubmit:
                        qnController.quiz.value.showResultEachSubmit == 1
                            ? true
                            : false,
                    correctAnswer:
                        widget.assign?.questionBank?.questionMu ?? [],
                    type: "M",
                    assign: widget.assign ?? Assign(),
                    data: {
                      "type": "M",
                      "assign_id": widget.assign?.id,
                      "quiz_test_id":
                          qnController.quizController.quizStart.value.data?.id,
                      "ans": assignIds,
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      } else if (widget.assign?.questionBank?.type == "S") {
        return Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            padding: EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                ListView(
                  children: [
                    HtmlWidget(
                      '''
                      ${widget.assign?.questionBank?.question ?? "____"}
                      ''',
                      textStyle: Get.textTheme.titleSmall
                          ?.copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 20.0 / 2),
                    TextFormField(
                      controller: shortAnsCtrl,
                      maxLines: 2,
                      cursorColor: Get.theme.primaryColor,
                      style: Get.textTheme.titleSmall
                          ?.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Get.theme.primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                      enabled: !qnController.answered[widget.index ?? 0]
                          ? true
                          : false,
                      validator: (value) {
                        if (value?.length == 0) {
                          return TranslationHelper.tr("Please type something");
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
                ContinueSkipSubmitBtn(
                  qnController: qnController,
                  index: widget.index ?? 0,
                  showEachSubmit:
                      qnController.quiz.value.showResultEachSubmit == 1
                          ? true
                          : false,
                  formKey: _formKey,
                  type: "S",
                  assign: widget.assign ?? Assign(),
                  data: {
                    "type": "S",
                    "assign_id": widget.assign?.id,
                    "quiz_test_id":
                        qnController.quizController.quizStart.value.data?.id,
                    "ans": shortAnsCtrl.text,
                  },
                ),
              ],
            ),
          ),
        );
      } else if (widget.assign?.questionBank?.type == "L") {
        return Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            padding: EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                ListView(
                  children: [
                    HtmlWidget(
                      '''
                      ${widget.assign?.questionBank?.question ?? "____"}
                      ''',
                      textStyle: Get.textTheme.titleSmall
                          ?.copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 20.0 / 2),
                    TextFormField(
                      controller: longAnsCtrl,
                      maxLines: 5,
                      cursorColor: Get.theme.primaryColor,
                      style: Get.textTheme.titleSmall
                          ?.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Get.theme.primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                      enabled: !qnController.answered[widget.index ?? 0]
                          ? true
                          : false,
                      validator: (value) {
                        if (value?.length == 0) {
                          return TranslationHelper.tr("Please type something");
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
                ContinueSkipSubmitBtn(
                  qnController: qnController,
                  index: widget.index ?? 0,
                  showEachSubmit:
                      qnController.quiz.value.showResultEachSubmit == 1
                          ? true
                          : false,
                  formKey: _formKey,
                  type: "L",
                  assign: widget.assign ?? Assign(),
                  data: {
                    "type": "L",
                    "assign_id": widget.assign?.id,
                    "quiz_test_id":
                        qnController.quizController.quizStart.value.data?.id,
                    "ans": longAnsCtrl.text,
                  },
                ),
              ],
            ),
          ),
        );
      }
      return Container();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
