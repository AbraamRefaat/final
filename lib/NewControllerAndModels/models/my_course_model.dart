class MyCourseModel {
  final int id;
  final String title;
  final String image;
  final String thumbnail;
  final double price;
  final double discountPrice;
  final double purchasePrice;
  final String assignedInstructor;
  final int totalCompletePercentage;
  final String? slug;
  final String? duration;
  final int? langId;
  final int? categoryId;
  final int? userId;
  final int? level;
  final int? totalEnrolled;
  final String? instructorName;
  final String? instructorImage;
  final String? levelTitle;
  final int? totalChapters;
  final int? totalLessons;

  MyCourseModel({
    required this.id,
    required this.title,
    required this.image,
    required this.thumbnail,
    required this.price,
    required this.discountPrice,
    required this.purchasePrice,
    required this.assignedInstructor,
    required this.totalCompletePercentage,
    this.slug,
    this.duration,
    this.langId,
    this.categoryId,
    this.userId,
    this.level,
    this.totalEnrolled,
    this.instructorName,
    this.instructorImage,
    this.levelTitle,
    this.totalChapters,
    this.totalLessons,
  });

  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    // Handle title - it might be an object with language keys or a string
    String title = "Unknown Title";
    if (json['title'] != null) {
      if (json['title'] is Map<String, dynamic>) {
        // If title is an object with language keys, try to get English first, then Arabic
        var titleObj = json['title'] as Map<String, dynamic>;
        title = titleObj['en'] ?? titleObj['ar'] ?? "Unknown Title";
      } else if (json['title'] is String) {
        title = json['title'];
      }
    }

    // Extract instructor information from user object
    String instructorName = "Unknown Instructor";
    String instructorImage = "";
    if (json['user'] != null) {
      var userObj = json['user'] as Map<String, dynamic>;
      instructorName =
          userObj['name'] ?? userObj['first_name'] ?? "Unknown Instructor";
      instructorImage = userObj['image'] ?? userObj['avatar'] ?? "";
    }

    // Extract level title from course_level object
    String levelTitle = "";
    if (json['course_level'] != null) {
      var levelObj = json['course_level'] as Map<String, dynamic>;
      if (levelObj['title'] != null) {
        if (levelObj['title'] is Map<String, dynamic>) {
          var levelTitleObj = levelObj['title'] as Map<String, dynamic>;
          levelTitle = levelTitleObj['en'] ?? levelTitleObj['ar'] ?? "";
        } else if (levelObj['title'] is String) {
          levelTitle = levelObj['title'];
        }
      }
    }

    return MyCourseModel(
      id: json['id'] ?? 0, // Default to 0 if null
      title: title,
      image: json['image'] ?? "", // Default to empty string
      thumbnail: json['thumbnail'] ?? "", // Default to empty string
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      discountPrice:
          (json['discount_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      purchasePrice:
          (json['purchase_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      assignedInstructor: instructorName,
      totalCompletePercentage: json['total_percentage'] ??
          json['totalCompletePercentage'] ??
          0, // Default to 0
      slug: json['slug'],
      duration: json['duration']?.toString(),
      langId: json['lang_id'],
      categoryId: json['category_id'],
      userId: json['user_id'],
      level: json['level'],
      totalEnrolled: json['total_enrolled'],
      instructorName: instructorName,
      instructorImage: instructorImage,
      levelTitle: levelTitle,
      totalChapters: json['total_chapters'],
      totalLessons: json['total_lessons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'thumbnail': thumbnail,
      'price': price,
      'discount_price': discountPrice,
      'purchase_price': purchasePrice,
      'assigned_instructor': assignedInstructor,
      'totalCompletePercentage': totalCompletePercentage,
      'slug': slug,
      'duration': duration,
      'lang_id': langId,
      'category_id': categoryId,
      'user_id': userId,
      'level': level,
      'total_enrolled': totalEnrolled,
      'instructor_name': instructorName,
      'instructor_image': instructorImage,
      'level_title': levelTitle,
      'total_chapters': totalChapters,
      'total_lessons': totalLessons,
    };
  }
}
