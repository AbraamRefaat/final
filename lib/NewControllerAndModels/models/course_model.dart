// course_model.dart
import '../../utils/localization_helper.dart';
import '../../Config/app_config.dart';

class Course {
  final int id;
  final String title;
  final String image;
  final String thumbnail;
  final double price;
  final double discountPrice;
  final String assignedInstructor;
  final double purchasePrice;
  final int quizId;

  Course({
    required this.id,
    required this.title,
    required this.image,
    required this.thumbnail,
    required this.price,
    required this.discountPrice,
    required this.assignedInstructor,
    required this.purchasePrice,
    required this.quizId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Build full image URL if path exists
    String buildImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return '';
      // If it's already a full URL, return as is
      if (imagePath.startsWith('http')) return imagePath;
      // Build full URL from base URL + path
      return rootUrl + '/' + imagePath;
    }

    // Extract instructor name from user object
    String getInstructorName() {
      try {
        if (json['user'] != null && json['user']['name'] != null) {
          return json['user']['name'].toString();
        }
        // Fallback to instructors field if user field doesn't exist
        if (json['instructors'] != null &&
            json['instructors']['name'] != null) {
          return json['instructors']['name'].toString();
        }
        // Last fallback to assigned_instructor field
        if (json['assigned_instructor'] != null &&
            json['assigned_instructor'].toString().isNotEmpty) {
          return json['assigned_instructor'].toString();
        }
        return 'غير محدد'; // "Not specified" in Arabic
      } catch (e) {
        return 'غير محدد';
      }
    }

    return Course(
      id: json['id'] ?? 0,
      title: LocalizationHelper.extractLocalizedText(json['title']) ??
          'بدون عنوان', // "No title" in Arabic
      image: buildImageUrl(json['image']),
      thumbnail: buildImageUrl(json['thumbnail']),
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      discountPrice: (json['discount_price'] != null)
          ? double.tryParse(json['discount_price'].toString()) ?? 0.0
          : 0.0,
      assignedInstructor: getInstructorName(),
      purchasePrice: (json['purchase_price'] != null)
          ? double.tryParse(json['purchase_price'].toString()) ?? 0.0
          : 0.0,
      quizId: json['quiz_id'] ?? 0,
    );
  }
}
