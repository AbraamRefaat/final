// To parse this JSON data, do
//
//     final topCategory = topCategoryFromJson(jsonString);

// Dart imports:
import 'dart:convert';

List<TopCategory> topCategoryFromJson(String str) =>
    List<TopCategory>.from(json.decode(str).map((x) => TopCategory.fromJson(x)))
        .where((element) => element.courseCount != 0)
        .toList();

String topCategoryToJson(List<TopCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopCategory {
  TopCategory({
    this.id,
    this.name,
    this.courseCount,
  });

  dynamic id;
  String? name;

  dynamic courseCount;

  factory TopCategory.fromJson(dynamic json) => TopCategory(
        id: json["id"],
        name: json["name"],
        courseCount: json["course_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "course_count": courseCount,
      };
}
