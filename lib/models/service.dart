import 'package:flutter/material.dart';

class SalonService {
  final String id;
  final String name;
  final String description;
  final int baseDurationMin;
  final int baseDurationMax;
  final String icon;
  final List<String>? assignedStylistIds;

  const SalonService({
    required this.id,
    required this.name,
    required this.description,
    required this.baseDurationMin,
    required this.baseDurationMax,
    required this.icon,
    this.assignedStylistIds,
  });

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      baseDurationMin: json['baseDurationMin'] as int? ?? 30,
      baseDurationMax: json['baseDurationMax'] as int? ?? 60,
      icon: json['icon'] as String? ?? 'spa',
      assignedStylistIds: (json['assignedStylistIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'baseDurationMin': baseDurationMin,
        'baseDurationMax': baseDurationMax,
        'icon': icon,
        'assignedStylistIds': assignedStylistIds,
      };

  IconData get iconData {
    switch (icon) {
      case 'content_cut':
        return Icons.content_cut;
      case 'brush':
        return Icons.brush;
      case 'palette':
        return Icons.palette;
      case 'healing':
        return Icons.healing;
      case 'spa':
        return Icons.spa;
      case 'back_hand':
        return Icons.back_hand;
      case 'favorite':
        return Icons.favorite;
      case 'face':
        return Icons.face;
      case 'school':
        return Icons.school;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'brush_outlined':
        return Icons.brush_outlined;
      default:
        return Icons.spa;
    }
  }

  SalonService copyWith({
    String? id,
    String? name,
    String? description,
    int? baseDurationMin,
    int? baseDurationMax,
    String? icon,
    List<String>? assignedStylistIds,
  }) {
    return SalonService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseDurationMin: baseDurationMin ?? this.baseDurationMin,
      baseDurationMax: baseDurationMax ?? this.baseDurationMax,
      icon: icon ?? this.icon,
      assignedStylistIds: assignedStylistIds ?? this.assignedStylistIds,
    );
  }
}

/// Hardcoded initial service list (11 services).
class ServiceData {
  ServiceData._();

  static List<SalonService> get initialServices => [
        const SalonService(
          id: '1',
          name: 'Haircut',
          description:
              'Professional haircut tailored to your face shape and style preferences.',
          baseDurationMin: 30,
          baseDurationMax: 60,
          icon: 'content_cut',
        ),
        const SalonService(
          id: '2',
          name: 'Styling',
          description:
              'Blow-dry, curling, straightening, and occasion-ready styling.',
          baseDurationMin: 30,
          baseDurationMax: 90,
          icon: 'brush',
        ),
        const SalonService(
          id: '3',
          name: 'Color',
          description:
              'Full color, highlights, balayage, and root touch-up services.',
          baseDurationMin: 60,
          baseDurationMax: 180,
          icon: 'palette',
        ),
        const SalonService(
          id: '4',
          name: 'Hair treatment',
          description:
              'Deep conditioning, keratin, and restorative hair treatments.',
          baseDurationMin: 45,
          baseDurationMax: 120,
          icon: 'healing',
        ),
        const SalonService(
          id: '5',
          name: 'Body spa',
          description:
              'Relaxing full-body spa with massage and aromatherapy.',
          baseDurationMin: 60,
          baseDurationMax: 120,
          icon: 'spa',
        ),
        const SalonService(
          id: '6',
          name: 'Mani/pedi',
          description:
              'Manicure and pedicure with nail art options.',
          baseDurationMin: 45,
          baseDurationMax: 90,
          icon: 'back_hand',
        ),
        const SalonService(
          id: '7',
          name: 'Bridal',
          description:
              'Complete bridal makeup, hair, and pre-wedding packages.',
          baseDurationMin: 120,
          baseDurationMax: 240,
          icon: 'favorite',
        ),
        const SalonService(
          id: '8',
          name: 'Facial',
          description:
              'Cleansing, exfoliation, and rejuvenating facial treatments.',
          baseDurationMin: 45,
          baseDurationMax: 90,
          icon: 'face',
        ),
        const SalonService(
          id: '9',
          name: 'Beautician classes',
          description:
              'Professional beautician training and certification courses.',
          baseDurationMin: 120,
          baseDurationMax: 240,
          icon: 'school',
        ),
        const SalonService(
          id: '10',
          name: 'Waxing',
          description:
              'Full body and targeted waxing with premium products.',
          baseDurationMin: 30,
          baseDurationMax: 90,
          icon: 'cleaning_services',
        ),
        const SalonService(
          id: '11',
          name: 'Mehedi',
          description:
              'Traditional and contemporary henna designs for all occasions.',
          baseDurationMin: 60,
          baseDurationMax: 180,
          icon: 'brush_outlined',
        ),
      ];
}
