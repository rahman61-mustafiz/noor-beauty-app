class AdminUser {
  final String id;
  final String email;
  final bool mfaEnabled;
  final String? mfaSecret;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AdminUser({
    required this.id,
    required this.email,
    this.mfaEnabled = false,
    this.mfaSecret,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
      mfaSecret: json['mfaSecret'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'mfaEnabled': mfaEnabled,
        'mfaSecret': mfaSecret,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
      };
}

class AdminDashboardData {
  final int todayBookings;
  final int upcomingBookings;
  final int totalCustomers;
  final List<BookingSummary> recentBookings;

  const AdminDashboardData({
    required this.todayBookings,
    required this.upcomingBookings,
    required this.totalCustomers,
    required this.recentBookings,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      todayBookings: json['todayBookings'] as int? ?? 0,
      upcomingBookings: json['upcomingBookings'] as int? ?? 0,
      totalCustomers: json['totalCustomers'] as int? ?? 0,
      recentBookings: (json['recentBookings'] as List<dynamic>?)
              ?.map((e) => BookingSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BookingSummary {
  final String id;
  final String customerName;
  final String serviceName;
  final String stylistName;
  final String startTime;
  final String status;

  const BookingSummary({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.stylistName,
    required this.startTime,
    required this.status,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      stylistName: json['stylistName'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class AnalyticsData {
  final List<ServiceStat> topServices;
  final List<StylistStat> topStylists;
  final List<MonthlyTrend> monthlyTrends;
  final double retentionRate;

  const AnalyticsData({
    required this.topServices,
    required this.topStylists,
    required this.monthlyTrends,
    required this.retentionRate,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      topServices: (json['topServices'] as List<dynamic>?)
              ?.map((e) => ServiceStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topStylists: (json['topStylists'] as List<dynamic>?)
              ?.map((e) => StylistStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyTrends: (json['monthlyTrends'] as List<dynamic>?)
              ?.map((e) => MonthlyTrend.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ServiceStat {
  final String name;
  final int count;

  const ServiceStat({required this.name, required this.count});

  factory ServiceStat.fromJson(Map<String, dynamic> json) => ServiceStat(
        name: json['name'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );
}

class StylistStat {
  final String name;
  final int bookings;
  final double rating;

  const StylistStat({
    required this.name,
    required this.bookings,
    required this.rating,
  });

  factory StylistStat.fromJson(Map<String, dynamic> json) => StylistStat(
        name: json['name'] as String? ?? '',
        bookings: json['bookings'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      );
}

class MonthlyTrend {
  final String month;
  final int bookings;
  final int newCustomers;

  const MonthlyTrend({
    required this.month,
    required this.bookings,
    required this.newCustomers,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) => MonthlyTrend(
        month: json['month'] as String? ?? '',
        bookings: json['bookings'] as int? ?? 0,
        newCustomers: json['newCustomers'] as int? ?? 0,
      );
}
