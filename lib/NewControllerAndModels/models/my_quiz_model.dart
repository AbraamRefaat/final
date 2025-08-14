class MyQuizModel {
  final int id;
  final int quizId;
  final String title;
  final String image;
  final String thumbnail;
  final double price;
  final double discountPrice;
  final double purchasePrice;
  final String assignedInstructor;

  MyQuizModel({
    required this.id,
    required this.quizId,
    required this.title,
    required this.image,
    required this.thumbnail,
    required this.price,
    required this.discountPrice,
    required this.purchasePrice,
    required this.assignedInstructor,
  });

  factory MyQuizModel.fromJson(Map<String, dynamic> json) {
    return MyQuizModel(
      id: json['id'] ?? 0, // Default to 0 if null
      quizId: json['quiz_id'] ?? 0, // Default to 0 if null
      title: json['title'] ?? "Unknown Title", // Default title
      image: json['image'] ?? "", // Default to empty string
      thumbnail: json['thumbnail'] ?? "", // Default to empty string
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      discountPrice:
          (json['discount_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      purchasePrice:
          (json['purchase_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      assignedInstructor: json['assigned_instructor'] ??
          "Unknown Instructor", // Default instructor
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'title': title,
      'image': image,
      'thumbnail': thumbnail,
      'price': price,
      'discount_price': discountPrice,
      'purchase_price': purchasePrice,
      'assigned_instructor': assignedInstructor,
    };
  }
}
