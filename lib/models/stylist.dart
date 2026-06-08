class Stylist {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> specialties;
  final String bio;
  final String? photo;
  final double rating;
  final DateTime createdAt;
  final Map<String, dynamic>? availability;

  const Stylist({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialties,
    required this.bio,
    this.photo,
    this.rating = 0.0,
    required this.createdAt,
    this.availability,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bio: json['bio'] as String? ?? '',
      photo: json['photo'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      availability: json['availability'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'specialties': specialties,
        'bio': bio,
        'photo': photo,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
        'availability': availability,
      };

  Stylist copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<String>? specialties,
    String? bio,
    String? photo,
    double? rating,
    DateTime? createdAt,
    Map<String, dynamic>? availability,
  }) {
    return Stylist(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialties: specialties ?? this.specialties,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      availability: availability ?? this.availability,
    );
  }
}

/// Hardcoded initial staff list for Noor Beauty Salon (10 stylists).
class StylistData {
  StylistData._();

  static List<Stylist> get initialStylists => [
        Stylist(
          id: '1',
          name: 'Fatima Rahman',
          email: 'fatima@noorbeauty.com',
          phone: '+8801712345001',
          specialties: ['Haircut', 'Styling', 'Color'],
          bio: 'Senior hair stylist with 8 years of experience in modern cuts and color.',
          rating: 4.8,
          createdAt: DateTime(2020, 3, 15),
        ),
        Stylist(
          id: '2',
          name: 'Nusrat Jahan',
          email: 'nusrat@noorbeauty.com',
          phone: '+8801712345002',
          specialties: ['Bridal', 'Mehedi', 'Styling'],
          bio: 'Bridal specialist known for elegant updos and traditional mehedi designs.',
          rating: 4.9,
          createdAt: DateTime(2019, 6, 20),
        ),
        Stylist(
          id: '3',
          name: 'Ayesha Siddiqua',
          email: 'ayesha@noorbeauty.com',
          phone: '+8801712345003',
          specialties: ['Facial', 'Body spa', 'Waxing'],
          bio: 'Skincare expert specializing in rejuvenating facials and spa treatments.',
          rating: 4.7,
          createdAt: DateTime(2021, 1, 10),
        ),
        Stylist(
          id: '4',
          name: 'Sabrina Akter',
          email: 'sabrina@noorbeauty.com',
          phone: '+8801712345004',
          specialties: ['Mani/pedi', 'Waxing', 'Facial'],
          bio: 'Nail art and manicure specialist with attention to detail.',
          rating: 4.6,
          createdAt: DateTime(2020, 8, 5),
        ),
        Stylist(
          id: '5',
          name: 'Tasnim Haque',
          email: 'tasnim@noorbeauty.com',
          phone: '+8801712345005',
          specialties: ['Hair treatment', 'Color', 'Haircut'],
          bio: 'Hair health expert focused on treatments and restorative color work.',
          rating: 4.8,
          createdAt: DateTime(2018, 11, 12),
        ),
        Stylist(
          id: '6',
          name: 'Rumana Islam',
          email: 'rumana@noorbeauty.com',
          phone: '+8801712345006',
          specialties: ['Beautician classes', 'Facial', 'Mani/pedi'],
          bio: 'Certified beautician trainer with a passion for teaching.',
          rating: 4.5,
          createdAt: DateTime(2022, 2, 28),
        ),
        Stylist(
          id: '7',
          name: 'Sharmin Chowdhury',
          email: 'sharmin@noorbeauty.com',
          phone: '+8801712345007',
          specialties: ['Styling', 'Bridal', 'Haircut'],
          bio: 'Creative stylist specializing in occasion-ready looks.',
          rating: 4.7,
          createdAt: DateTime(2019, 9, 3),
        ),
        Stylist(
          id: '8',
          name: 'Maliha Khan',
          email: 'maliha@noorbeauty.com',
          phone: '+8801712345008',
          specialties: ['Mehedi', 'Bridal', 'Styling'],
          bio: 'Traditional and contemporary mehedi artist for weddings and events.',
          rating: 4.9,
          createdAt: DateTime(2020, 5, 18),
        ),
        Stylist(
          id: '9',
          name: 'Priya Das',
          email: 'priya@noorbeauty.com',
          phone: '+8801712345009',
          specialties: ['Body spa', 'Facial', 'Hair treatment'],
          bio: 'Wellness therapist offering relaxing spa and treatment packages.',
          rating: 4.6,
          createdAt: DateTime(2021, 7, 22),
        ),
        Stylist(
          id: '10',
          name: 'Zara Ahmed',
          email: 'zara@noorbeauty.com',
          phone: '+8801712345010',
          specialties: ['Waxing', 'Mani/pedi', 'Facial'],
          bio: 'Full-service beauty technician with a gentle touch.',
          rating: 4.5,
          createdAt: DateTime(2022, 4, 8),
        ),
      ];
}
