import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Model/Course/CourseMain.dart';

class CartList {
  CartList({
    this.id,
    this.courseId,
    this.tracking,
    this.price,
    this.course,
  });

  dynamic id;
  dynamic courseId;
  String? tracking;
  double? price;
  CourseMain? course;

  factory CartList.fromJson(Map<String, dynamic> json) => CartList(
        id: json["id"],
        courseId: json["course_id"],
        tracking: json["tracking"]?.toString(),
        price: double.tryParse(json["price"].toString()) ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "course_id": courseId,
        "tracking": tracking,
        "price": price,
        "course": course?.toJson(),
      };

  static Future<CartList> createWithCourseDetails(
      Map<String, dynamic> json) async {
    CartList cart = CartList.fromJson(json);
    if (cart.courseId != null) {
      cart.course = await getCourseDetails(cart.courseId);
    }
    return cart;
  }

  static Future<CourseMain?> getCourseDetails(int id) async {
    try {
      Uri topCatUrl = Uri.parse('$baseUrl/get-course-details/$id');
      var response = await http.get(topCatUrl, headers: header());
      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var courseData = jsonEncode(jsonString['data']);
        return CourseMain.fromJson(json.decode(courseData));
      } else {
        // Handle error case
        return null;
      }
    } catch (e) {
      print('❌ Error getting course details for cart: $e');
      return null;
    }
  }
}
