class User {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? profilePic;
  final bool isBanned;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.profilePic,
    this.isBanned = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
      isBanned: json['isBanned'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profilePic': profilePic,
        'isBanned': isBanned,
        'createdAt': createdAt.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
