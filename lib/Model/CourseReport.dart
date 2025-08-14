// To parse this JSON data, do
//
//     final courseReport = courseReportFromJson(jsonString);

import 'dart:convert';

CourseReport courseReportFromJson(String str) =>
    CourseReport.fromJson(json.decode(str));

String courseReportToJson(CourseReport data) => json.encode(data.toJson());

class CourseReport {
  bool? success;
  String? message;
  CourseReportData? data;

  CourseReport({
    this.success,
    this.message,
    this.data,
  });

  factory CourseReport.fromJson(Map<String, dynamic> json) => CourseReport(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : CourseReportData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class CourseReportData {
  List<EnrolledCourse>? courses;

  CourseReportData({
    this.courses,
  });

  factory CourseReportData.fromJson(dynamic json) {
    if (json is List) {
      // If data is directly an array of courses
      return CourseReportData(
        courses: List<EnrolledCourse>.from(
            json.map((x) => EnrolledCourse.fromJson(x))),
      );
    } else if (json is Map<String, dynamic>) {
      // If data is an object containing courses array
      var coursesData = json["courses"] ?? json["data"] ?? [];
      return CourseReportData(
        courses: List<EnrolledCourse>.from(
            coursesData.map((x) => EnrolledCourse.fromJson(x))),
      );
    }
    return CourseReportData(courses: []);
  }

  Map<String, dynamic> toJson() => {
        "courses": courses?.map((x) => x.toJson()).toList(),
      };

  // Helper methods to get counts
  int get enrolledCoursesCount => courses?.length ?? 0;

  int get finishedCoursesCount {
    if (courses == null) return 0;
    return courses!
        .where((course) =>
            course.courseStatus == "Completed" || course.percentage == 100)
        .length;
  }

  int get inProgressCoursesCount {
    if (courses == null) return 0;
    return courses!
        .where((course) =>
            course.courseStatus != "Completed" &&
            course.courseStatus != "Not Started yet" &&
            (course.percentage ?? 0) > 0 &&
            (course.percentage ?? 0) < 100)
        .length;
  }

  int get notStartedCoursesCount {
    if (courses == null) return 0;
    return courses!
        .where((course) =>
            course.courseStatus == "Not Started yet" ||
            (course.percentage ?? 0) == 0)
        .length;
  }
}

class EnrolledCourse {
  int? id;
  String? tracking;
  int? userId;
  int? courseId;
  String? courseStatus;
  int? percentage;
  String? completionRate;
  String? completionDate;
  String? enrolledDate;

  EnrolledCourse({
    this.id,
    this.tracking,
    this.userId,
    this.courseId,
    this.courseStatus,
    this.percentage,
    this.completionRate,
    this.completionDate,
    this.enrolledDate,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) => EnrolledCourse(
        id: json["id"],
        tracking: json["tracking"],
        userId: json["user_id"],
        courseId: json["course_id"],
        courseStatus: json["courseStatus"],
        percentage: json["percentage"],
        completionRate: json["completionRate"],
        completionDate: json["completionDate"],
        enrolledDate: json["enrolledDate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tracking": tracking,
        "user_id": userId,
        "course_id": courseId,
        "courseStatus": courseStatus,
        "percentage": percentage,
        "completionRate": completionRate,
        "completionDate": completionDate,
        "enrolledDate": enrolledDate,
      };
}
