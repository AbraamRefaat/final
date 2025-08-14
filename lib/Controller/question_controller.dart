// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Model/Quiz/Assign.dart';
import 'package:untitled2/Model/Quiz/QuestionResultModel.dart';
import 'package:untitled2/Service/RemoteService.dart';
import 'package:untitled2/Service/quiz_service.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/my_quiz_result_summary.dart';

import '../Model/Quiz/Quiz.dart';

class QuestionController extends GetxController
    with GetTickerProviderStateMixin {
  final QuizController quizController =
      Get.find<QuizController>(); // Use find instead of put

  AnimationController? _animationController;
  Animation? _animation;

  Animation? get animation => this._animation;

  PageController? _pageController;

  PageController? get pageController => this._pageController;

  var questions = <Assign>[].obs;

  var quiz = Quiz().obs;

  bool _isAnswered = false;

  bool get isAnswered => this._isAnswered;

  CheckboxModal? _correctAns;

  CheckboxModal? get correctAns => this._correctAns;

  CheckboxModal? _selectedAns;

  CheckboxModal? get selectedAns => this._selectedAns;

  RxInt _questionNumber = 1.obs;

  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;

  int get numOfCorrectAns => this._numOfCorrectAns;

  var questionTime = 1.obs;

  var currentQuestion = Assign().obs;

  var isSelected = false.obs;

  GetStorage userToken = GetStorage();

  var tokenKey = "token";

  var submitSingleAnswer = false.obs;

  var questionResult = QuizResultModel().obs;

  var quizResultLoading = false.obs;

  RxList<bool> answered = <bool>[].obs;

  var types = [].obs;

  // Store student answers for each question
  RxList<List<String>> studentAnswers = <List<String>>[].obs;

  @override
  void onInit() {
    _animationController = AnimationController(
        duration: Duration(seconds: questionTime.value * 60), vsync: this);
    super.onInit();
  }

  void startController(quizParam) {
    questionNumber.value = 1;
    answered.clear();
    types.clear();
    studentAnswers.clear();
    quiz.value = quizParam;

    // Disable showing answers after each question
    quiz.value.showResultEachSubmit = 0;

    questionTime.value = quiz.value.questionTime ?? 0;
    if (quiz.value.randomQuestion == 1) {
      // Randomize Question
      questions.value = (quiz.value.assign?..shuffle())!;
    } else {
      questions.value = quiz.value.assign ?? [];
    }
    questions.forEach((element) {
      answered.add(false);
      types.add(element.questionBank?.type);
      studentAnswers.add([]); // Initialize empty answer list for each question
    });
    currentQuestion.value = quiz.value.assign!.first;
    _animationController = AnimationController(
        duration: Duration(seconds: questionTime.value * 60), vsync: this);
    _animation = StepTween(begin: questionTime.value * 60, end: 0)
        .animate(_animationController as Animation<double>)
      ..addListener(() {
        update();
      });
    if (quiz.value.questionTimeType == 0) {
      _animationController?.forward().whenComplete(() {
        skipPress(0);
      });
    } else {
      _animationController?.forward().whenComplete(finalSubmit);
    }

    if (_questionNumber.value == quiz.value.assign?.length) {
      lastQuestion.value = true;
    } else {
      lastQuestion.value = false;
    }

    _pageController = PageController();
  }

  @override
  void onClose() {
    super.onClose();
    _animationController?.dispose();
    _pageController?.dispose();
  }

  Future finalSubmit() async {
    _animationController?.stop();
    await questionResultPreview(quizController.quizStart.value.data?.id, true)
        .then((value) {
      _animationController?.stop();
      // Get.back();
      // Get.to(() => QuizResultScreen());
      Get.to(() => MyQuizResultSummary());
    });
  }

  var checkSelectedIndex = 0.obs;
  var lastQuestion = false.obs;

  var color = Colors.white.obs;

  void questionSelect(index) {
    currentQuestion.value = quiz.value.assign![index];

    _pageController?.animateToPage(index,
        curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
    if (quiz.value.questionTimeType == 0) {
      // print("ZERO Q TYPE => ${quiz.value.questionTimeType}");
      _animationController?.reset();
      _animationController?.forward().whenComplete(() {
        skipPress(index);
      });
    } else {
      // print("ONE Q TYPE => ${quiz.value.questionTimeType}");
    }
  }

  bool checkSelected(index) {
    return currentQuestion.value == quiz.value.assign?[index] ? true : false;
  }

  Future skipPress(index) async {
    if (_questionNumber.value != quiz.value.assign?.length) {
      currentQuestion.value = quiz.value.assign?[index + 1] ?? Assign();
      if (quiz.value.showResultEachSubmit == 1) {
        Future.delayed(Duration(seconds: 3), () {
          _pageController?.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          if (quiz.value.questionTimeType == 0) {
            _animationController?.reset();
            _animationController?.forward().whenComplete(() {
              skipPress(index);
            });
          }
        });
      } else {
        _pageController?.nextPage(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        if (quiz.value.questionTimeType == 0) {
          _animationController?.reset();
          _animationController?.forward().whenComplete(() {
            skipPress(index);
          });
        }
      }
    } else {
      await questionResultPreview(quizController.quizStart.value.data?.id, true)
          .then((value) {
        _animationController?.stop();
        // Get.back();
        // Get.to(() => QuizResultScreen());
        Get.to(() => MyQuizResultSummary());
      });
    }
  }

  void singleDone() {
    questionTime.value = quiz.value.questionTime ?? 0;
    currentQuestion.value =
        quiz.value.assign?[questionNumber.value] ?? Assign();
    _pageController?.nextPage(
        duration: Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  void continuePress() {}

  void submitPress() {}

  void updateTheQnNum(int index) {
    currentQuestion.value = quiz.value.assign?[index] ?? Assign();
    checkSelected(index);
    _questionNumber.value = index + 1;
    if (_questionNumber.value == quiz.value.assign?.length) {
      lastQuestion.value = true;
    } else {
      lastQuestion.value = false;
    }
  }

  Future<bool> singleSubmit(Map data, int index) async {
    try {
      var returnValue = false;
      String token = await userToken.read(tokenKey);
      submitSingleAnswer(true);

      print('📝 Submitting single answer for question ${index + 1}');
      print('🔍 Data: $data');

      // Extract required parameters from data
      int quizTestId =
          data['quiz_test_id'] ?? quizController.quizStart.value.data?.id ?? 0;
      int assignId = data['assign_id'] ?? currentQuestion.value.id ?? 0;
      String type =
          data['type'] ?? currentQuestion.value.questionBank?.type ?? 'M';
      dynamic answer = data['ans'] ?? [];

      print('🔍 Quiz Test ID: $quizTestId');
      print('🔍 Assign ID: $assignId');
      print('🔍 Type: $type');
      print('🔍 Answer: $answer');

      // Use the new QuizService for single question submission
      var value = await QuizService.submitSingleQuestion(
        token: token,
        quizTestId: quizTestId,
        assignId: assignId,
        type: type,
        answer: answer,
      );

      if (value) {
        answered[index] = true;
        // Store the student's answer
        studentAnswers[index] =
            (answer as List).map((a) => a.toString()).toList().cast<String>();
        returnValue = true;
        print('✅ Single answer submitted successfully');
        print('🔍 Stored answer for question $index: ${studentAnswers[index]}');
      } else {
        answered[index] = false;
        returnValue = false;
        print('❌ Single answer submission failed');
      }

      return returnValue;
    } catch (e) {
      print('Error in singleSubmit: $e');
      answered[index] = false;
      return false;
    } finally {
      submitSingleAnswer(false);
    }
  }

  Future questionResultPreview(int quizStartId, bool isPreview) async {
    quizResultLoading(true);
    try {
      // Submit final quiz first
      await finalQuizSubmit(quizStartId);

      // Get question result using the new QuizService
      String token = await userToken.read(tokenKey);
      var value = await QuizService.getQuestionResult(
        token: token,
        quizResultId: quizStartId,
      );

      questionResult.value = value ?? QuizResultModel();

      if (isPreview) {
        await quizController.getMyQuizDetails();
      }

      return questionResult.value;
    } catch (e) {
      print('Error in questionResultPreview: $e');
      return questionResult.value;
    } finally {
      quizResultLoading(false);
    }
  }

  Future getQuizResultPreview(int quizStartId) async {
    try {
      String token = await userToken.read(tokenKey);
      quizResultLoading(true);
      await RemoteServices.questionResult(
              token: token, quizResultId: quizStartId)
          .then((value) async {
        questionResult.value = value ?? QuizResultModel();
      });
      return questionResult.value;
    } finally {
      quizResultLoading(false);
    }
  }

  Future<bool> finalQuizSubmit(int quizStartId) async {
    try {
      // Use the new QuizService for final quiz submission
      String token = await userToken.read(tokenKey);

      print('🏁 Submitting final quiz...');
      print('🔍 Quiz Test ID: $quizStartId');
      print('🔍 Types list: $types');
      print('🔍 Types length: ${types.length}');
      print('🔍 Quiz assign length: ${quiz.value.assign?.length ?? 0}');

      // Ensure types list is not empty
      if (types.isEmpty) {
        print('⚠️ Types list is empty, generating from quiz questions...');
        types.clear();
        quiz.value.assign?.forEach((element) {
          types.add(element.questionBank?.type ?? 'M');
        });
        print('🔍 Generated types: $types');
      }

      // Convert types to List<String> as required by the new API
      List<String> questionTypes =
          types.map((type) => type.toString()).toList();

      print('🔍 Final question types: $questionTypes');

      var result = await QuizService.submitFinalQuiz(
        token: token,
        quizTestId: quizStartId,
        questionTypes: questionTypes,
      );

      if (result) {
        print('✅ Final quiz submitted successfully');
      } else {
        print('❌ Final quiz submission failed');
      }

      return result;
    } catch (e) {
      print('Error in finalQuizSubmit: $e');
      return false;
    }
  }

  String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  /// Calculate correct/incorrect answers based on website logic
  /// This matches the website's singleQusSubmit method logic
  List<Map<String, dynamic>> calculateStudentAnswers() {
    List<Map<String, dynamic>> studentAnswers = [];

    for (int i = 0; i < (quiz.value.assign?.length ?? 0); i++) {
      final question = quiz.value.assign![i];
      final questionType = question.questionBank?.type ?? 'M';
      final studentAnswer = answered[i] ? getStudentAnswerForQuestion(i) : [];

      bool isCorrect = false;

      if (questionType == 'M') {
        // Multiple Choice Questions
        // Get all correct answers for this question
        final correctOptions = question.questionBank?.questionMu
                ?.where((option) => option.status == 1)
                .map((option) => option.id.toString())
                .toList() ??
            [];

        final totalCorrectAns = correctOptions.length;
        int wrong = 0;
        int userCorrectAns = 0;

        // Check each answer the user selected
        for (String ans in studentAnswer) {
          final option = question.questionBank?.questionMu
              ?.firstWhere((opt) => opt.id.toString() == ans);

          if (option != null) {
            if (option.status == 0) {
              wrong++; // User selected a wrong answer
            } else if (option.status == 1) {
              userCorrectAns++; // User selected a correct answer
            }
          }
        }

        // Determine if the answer is correct (website logic)
        if (wrong == 0) {
          // No wrong answers selected
          if (userCorrectAns == totalCorrectAns) {
            isCorrect = true; // ✅ CORRECT
          } else {
            isCorrect = false; // ❌ PARTIALLY CORRECT
          }
        } else {
          isCorrect = false; // ❌ WRONG (selected wrong answer)
        }
      }

      studentAnswers.add({
        'assign_id': question.id,
        'ans': studentAnswer,
        'is_correct': isCorrect,
        'question_type': questionType,
      });
    }

    return studentAnswers;
  }

  /// Get student answer for a specific question
  List<String> getStudentAnswerForQuestion(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < studentAnswers.length) {
      return studentAnswers[questionIndex];
    }
    return [];
  }
}

class CheckboxModal {
  String? title;
  bool? value;
  int? id;
  int? status;

  CheckboxModal({this.title, this.value, this.id, this.status});
}
