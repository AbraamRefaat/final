// To parse this JSON data, do
//
//     final quizStartModel = quizStartModelFromJson(jsonString);

// Dart imports:
import 'dart:convert';

QuizStartModel quizStartModelFromJson(String str) =>
    QuizStartModel.fromJson(json.decode(str));

String quizStartModelToJson(QuizStartModel data) => json.encode(data.toJson());

class QuizStartModel {
  QuizStartModel({
    this.result,
    this.data,
  });

  bool? result;
  QData? data;

  factory QuizStartModel.fromJson(Map<String, dynamic> json) => QuizStartModel(
        result: json[
            "result"], // Changed from "success" to "result" to match API response
        data: json["data"] != null ? QData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "result":
            result, // Changed from "success" to "result" to match API response
        "data": data?.toJson(),
      };
}

class QData {
  QData({
    this.userId,
    this.courseId,
    this.quizId,
    this.quizType,
    this.startAt,
    this.endAt,
    this.duration,
    this.id,
  });

  dynamic userId;
  String? courseId;
  String? quizId;
  dynamic quizType;
  DateTime? startAt;
  dynamic endAt;
  dynamic duration;

  dynamic id;

  factory QData.fromJson(Map<String, dynamic> json) => QData(
        userId: json["user_id"],
        courseId: json["course_id"]?.toString(),
        quizId: json["quiz_id"]?.toString(),
        quizType: json["quiz_type"],
        startAt: DateTime.parse(json["start_at"]),
        endAt: json["end_at"],
        duration: json["duration"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "course_id": courseId,
        "quiz_id": quizId,
        "quiz_type": quizType,
        "start_at": startAt?.toIso8601String(),
        "end_at": endAt,
        "duration": duration,
        "id": id,
      };
}
