import 'dart:convert';
import '../../utils/localization_helper.dart';

class CourseLevel {
  CourseLevel({
    this.id,
    this.title,
  });

  int? id;
  String? title;

  factory CourseLevel.fromJson(Map<String, dynamic> json) => CourseLevel(
      id: json["id"] ?? 0,
      title: LocalizationHelper.extractLocalizedText(json["title"]) ?? '');

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
