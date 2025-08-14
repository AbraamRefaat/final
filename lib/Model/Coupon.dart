class Coupon {
  final int id;
  final String code;
  final String description;
  final double discountAmount;
  final String discountType; // 'percentage' or 'fixed'
  final DateTime validFrom;
  final DateTime validTo;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final List<int> applicableCourseIds; // Empty list means all courses

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.discountType,
    required this.validFrom,
    required this.validTo,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    required this.applicableCourseIds,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountAmount: json['discount_amount'].toDouble(),
      discountType: json['discount_type'],
      validFrom: DateTime.parse(json['valid_from']),
      validTo: DateTime.parse(json['valid_to']),
      maxUses: json['max_uses'],
      usedCount: json['used_count'],
      isActive: json['is_active'] == 1,
      applicableCourseIds: List<int>.from(json['applicable_course_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discount_amount': discountAmount,
      'discount_type': discountType,
      'valid_from': validFrom.toIso8601String(),
      'valid_to': validTo.toIso8601String(),
      'max_uses': maxUses,
      'used_count': usedCount,
      'is_active': isActive ? 1 : 0,
      'applicable_course_ids': applicableCourseIds,
    };
  }

  bool isValid() {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validTo) &&
        usedCount < maxUses;
  }

  bool isApplicableToCourse(int courseId) {
    return applicableCourseIds.isEmpty ||
        applicableCourseIds.contains(courseId);
  }
}
