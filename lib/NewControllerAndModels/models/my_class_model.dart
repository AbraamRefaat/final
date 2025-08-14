class MyClassModel {
  final int id;
  final String title;
  final String image;
  final String thumbnail;
  final double price;
  final double purchasePrice;
  final double discountPrice;
  final String assignedInstructor;

  MyClassModel({
    required this.id,
    required this.title,
    required this.image,
    required this.thumbnail,
    required this.price,
    required this.purchasePrice,
    required this.discountPrice,
    required this.assignedInstructor,
  });

  factory MyClassModel.fromJson(Map<String, dynamic> json) {
    return MyClassModel(
      id: json['id'] ?? 0, // Default to 0 if null
      title: json['title'] ?? "Unknown Title", // Default title
      image: json['image'] ?? "", // Default to empty string
      thumbnail: json['thumbnail'] ?? "", // Default to empty string
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      purchasePrice:
          (json['purchase_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      discountPrice:
          (json['discount_price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      assignedInstructor: json['assigned_instructor'] ??
          "Unknown Instructor", // Default instructor
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'thumbnail': thumbnail,
      'price': price,
      'purchase_price': purchasePrice,
      'discount_price': discountPrice,
      'assigned_instructor': assignedInstructor,
    };
  }
}
