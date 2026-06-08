class Review {
  final String id;
  final String bookingId;
  final String customerId;
  final String stylistId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;
  final String? adminResponse;
  final String? customerName;
  final String? stylistName;
  final String? serviceName;

  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.stylistId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    this.adminResponse,
    this.customerName,
    this.stylistName,
    this.serviceName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      stylistId: json['stylistId']?.toString() ?? '',
      rating: json['rating'] as int? ?? 0,
      reviewText: json['reviewText'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      adminResponse: json['adminResponse'] as String?,
      customerName: json['customerName'] as String?,
      stylistName: json['stylistName'] as String?,
      serviceName: json['serviceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'customerId': customerId,
        'stylistId': stylistId,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': createdAt.toIso8601String(),
        'adminResponse': adminResponse,
      };

  Review copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? stylistId,
    int? rating,
    String? reviewText,
    DateTime? createdAt,
    String? adminResponse,
    String? customerName,
    String? stylistName,
    String? serviceName,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      stylistId: stylistId ?? this.stylistId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      adminResponse: adminResponse ?? this.adminResponse,
      customerName: customerName ?? this.customerName,
      stylistName: stylistName ?? this.stylistName,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}
