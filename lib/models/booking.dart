class Booking {
  final String id;
  final String customerId;
  final String stylistId;
  final String serviceId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String status;
  final String? notesCustomer;
  final String? notesAdmin;
  final DateTime createdAt;

  // Populated from joins (optional)
  final String? customerName;
  final String? stylistName;
  final String? serviceName;

  const Booking({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.serviceId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.notesCustomer,
    this.notesAdmin,
    required this.createdAt,
    this.customerName,
    this.stylistName,
    this.serviceName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      stylistId: json['stylistId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'] as String)
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      status: json['status'] as String? ?? 'pending',
      notesCustomer: json['notesCustomer'] as String?,
      notesAdmin: json['notesAdmin'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      customerName: json['customerName'] as String?,
      stylistName: json['stylistName'] as String?,
      serviceName: json['serviceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'stylistId': stylistId,
        'serviceId': serviceId,
        'bookingDate': bookingDate.toIso8601String().split('T').first,
        'startTime': startTime,
        'endTime': endTime,
        'durationMinutes': durationMinutes,
        'status': status,
        'notesCustomer': notesCustomer,
        'notesAdmin': notesAdmin,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => isPending || isConfirmed;
  bool get canReschedule => isPending || isConfirmed;

  Booking copyWith({
    String? id,
    String? customerId,
    String? stylistId,
    String? serviceId,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    String? status,
    String? notesCustomer,
    String? notesAdmin,
    DateTime? createdAt,
    String? customerName,
    String? stylistName,
    String? serviceName,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      stylistId: stylistId ?? this.stylistId,
      serviceId: serviceId ?? this.serviceId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notesCustomer: notesCustomer ?? this.notesCustomer,
      notesAdmin: notesAdmin ?? this.notesAdmin,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      stylistName: stylistName ?? this.stylistName,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}
