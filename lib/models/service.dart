import 'package:flutter/material.dart';

class ServiceSubOption {
  final String name;
  final int durationMin;
  final int price;

  const ServiceSubOption({
    required this.name,
    required this.durationMin,
    required this.price,
  });

  factory ServiceSubOption.fromJson(Map<String, dynamic> json) => ServiceSubOption(
        name: json['name'] as String? ?? '',
        durationMin: json['durationMin'] as int? ?? 30,
        price: json['price'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationMin': durationMin,
        'price': price,
      };
}

class SalonService {
  final String id;
  final String name;
  final String description;
  final int baseDurationMin;
  final int baseDurationMax;
  final String icon;
  final int startingPrice;
  final List<ServiceSubOption> subOptions;
  final List<String>? assignedStylistIds;

  const SalonService({
    required this.id,
    required this.name,
    required this.description,
    required this.baseDurationMin,
    required this.baseDurationMax,
    required this.icon,
    this.startingPrice = 0,
    this.subOptions = const [],
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
      startingPrice: json['startingPrice'] as int? ?? 0,
      subOptions: (json['subOptions'] as List<dynamic>?)
              ?.map((e) => ServiceSubOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
        'startingPrice': startingPrice,
        'subOptions': subOptions.map((e) => e.toJson()).toList(),
        'assignedStylistIds': assignedStylistIds,
      };

  IconData get iconData {
    switch (icon) {
      case 'content_cut':             return Icons.content_cut;
      case 'brush':                   return Icons.brush;
      case 'palette':                 return Icons.palette;
      case 'healing':                 return Icons.healing;
      case 'spa':                     return Icons.spa;
      case 'back_hand':               return Icons.back_hand;
      case 'favorite':                return Icons.favorite;
      case 'face':                    return Icons.face;
      case 'cleaning_services':       return Icons.cleaning_services;
      case 'brush_outlined':          return Icons.brush_outlined;
      case 'extension':               return Icons.extension;
      case 'auto_awesome':            return Icons.auto_awesome;
      case 'visibility':              return Icons.visibility;
      case 'waves':                   return Icons.waves;
      case 'face_retouching_natural': return Icons.face_retouching_natural;
      case 'auto_fix_high':           return Icons.auto_fix_high;
      case 'diamond':                 return Icons.diamond;
      case 'star':                    return Icons.star;
      case 'local_offer':             return Icons.local_offer;
      case 'card_giftcard':           return Icons.card_giftcard;
      default:                        return Icons.spa;
    }
  }

  SalonService copyWith({
    String? id, String? name, String? description,
    int? baseDurationMin, int? baseDurationMax, String? icon,
    int? startingPrice, List<ServiceSubOption>? subOptions,
    List<String>? assignedStylistIds,
  }) => SalonService(
    id: id ?? this.id, name: name ?? this.name,
    description: description ?? this.description,
    baseDurationMin: baseDurationMin ?? this.baseDurationMin,
    baseDurationMax: baseDurationMax ?? this.baseDurationMax,
    icon: icon ?? this.icon, startingPrice: startingPrice ?? this.startingPrice,
    subOptions: subOptions ?? this.subOptions,
    assignedStylistIds: assignedStylistIds ?? this.assignedStylistIds,
  );
}

class ServiceData {
  ServiceData._();

  static List<SalonService> get initialServices => [

    // ── 01  Hair Style (Cut) ──────────────────────────────────────────────────
    const SalonService(
      id: '1',
      name: 'Hair Style',
      icon: 'content_cut',
      startingPrice: 300,
      baseDurationMin: 20,
      baseDurationMax: 60,
      description: 'Professional haircuts from basic to advanced styles.',
      subOptions: [
        ServiceSubOption(name: 'U Cut',               durationMin: 30, price: 300),
        ServiceSubOption(name: 'V Cut',               durationMin: 30, price: 300),
        ServiceSubOption(name: 'Straight Cut',        durationMin: 30, price: 300),
        ServiceSubOption(name: 'Front Layer',         durationMin: 30, price: 400),
        ServiceSubOption(name: 'Blank Cut',           durationMin: 30, price: 500),
        ServiceSubOption(name: 'Boy Cut',             durationMin: 30, price: 500),
        ServiceSubOption(name: 'Front Layer & Bangs', durationMin: 30, price: 600),
        ServiceSubOption(name: 'Trimming',            durationMin: 20, price: 600),
        ServiceSubOption(name: 'Diana Cut',           durationMin: 30, price: 600),
        ServiceSubOption(name: 'Bob Cut',             durationMin: 30, price: 600),
        ServiceSubOption(name: 'Tweak Cut',           durationMin: 30, price: 600),
        ServiceSubOption(name: 'Feather Cut',         durationMin: 45, price: 800),
        ServiceSubOption(name: 'Full Layer',          durationMin: 45, price: 800),
        ServiceSubOption(name: 'Step Cut',            durationMin: 45, price: 800),
        ServiceSubOption(name: 'Farah Cut',           durationMin: 45, price: 800),
        ServiceSubOption(name: 'Thai Bob Cut',        durationMin: 45, price: 800),
        ServiceSubOption(name: 'Emo Cut',             durationMin: 45, price: 800),
        ServiceSubOption(name: 'Butterfly Cut',       durationMin: 60, price: 1000),
        ServiceSubOption(name: 'Volume Layer',        durationMin: 60, price: 1000),
        ServiceSubOption(name: 'Razor Cut',           durationMin: 60, price: 1000),
      ],
    ),

    // ── 02  Hair Setting ──────────────────────────────────────────────────────
    const SalonService(
      id: '2',
      name: 'Hair Setting',
      icon: 'brush',
      startingPrice: 500,
      baseDurationMin: 20,
      baseDurationMax: 90,
      description: 'Blow-dry, buns, braids & occasion styling. Long hair may cost more.',
      subOptions: [
        ServiceSubOption(name: 'Hair Ornaments',      durationMin: 20, price: 500),
        ServiceSubOption(name: 'Front Setting',       durationMin: 30, price: 600),
        ServiceSubOption(name: 'Normal Bun',          durationMin: 30, price: 800),
        ServiceSubOption(name: 'Hair Flower',         durationMin: 30, price: 1000),
        ServiceSubOption(name: 'Messy Bun',           durationMin: 45, price: 1200),
        ServiceSubOption(name: 'Front Braid',         durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Pincer Braid',        durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Ringless',            durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Ring Braid',          durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Side Bun',            durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Hair Iron',           durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Blow Dry',            durationMin: 30, price: 2000),
        ServiceSubOption(name: 'Flower Bun',          durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Sleek Bun',           durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Pearl Bun',           durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Braid Bun',           durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Hair Curl – Medium',  durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Hair Wave – Medium',  durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Any Bun with Flower', durationMin: 60, price: 3000),
      ],
    ),

    // ── 03  Hair Color ────────────────────────────────────────────────────────
    const SalonService(
      id: '3',
      name: 'Hair Color',
      icon: 'palette',
      startingPrice: 300,
      baseDurationMin: 30,
      baseDurationMax: 180,
      description: 'Regular & Premium product options. Extra charge for previously colored hair.',
      subOptions: [
        ServiceSubOption(name: 'Stick – Regular',                durationMin: 30,  price: 300),
        ServiceSubOption(name: 'Stick – Premium',                durationMin: 30,  price: 500),
        ServiceSubOption(name: 'Funky Color Stick – Regular',    durationMin: 30,  price: 500),
        ServiceSubOption(name: 'Funky Color Stick – Premium',    durationMin: 30,  price: 1000),
        ServiceSubOption(name: 'Root Touch – Regular',           durationMin: 60,  price: 3000),
        ServiceSubOption(name: 'Root Touch – Premium',           durationMin: 60,  price: 3000),
        ServiceSubOption(name: 'Base Color – Regular',           durationMin: 90,  price: 3000),
        ServiceSubOption(name: 'Base Color – Premium',           durationMin: 90,  price: 6000),
        ServiceSubOption(name: 'Cap Stick – Regular',            durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Cap Stick – Premium',            durationMin: 90,  price: 8000),
        ServiceSubOption(name: 'Cap Stick with Base – Regular',  durationMin: 120, price: 5000),
        ServiceSubOption(name: 'Cap Stick with Base – Premium',  durationMin: 120, price: 10000),
        ServiceSubOption(name: 'Foil Stick – Regular',           durationMin: 120, price: 6000),
        ServiceSubOption(name: 'Foil Stick – Premium',           durationMin: 120, price: 10000),
        ServiceSubOption(name: 'Highlight – Regular',            durationMin: 120, price: 6000),
        ServiceSubOption(name: 'Highlight – Premium',            durationMin: 120, price: 10000),
        ServiceSubOption(name: 'Balayage – Regular',             durationMin: 180, price: 7000),
        ServiceSubOption(name: 'Balayage – Premium',             durationMin: 180, price: 12000),
        ServiceSubOption(name: 'Ombre – Regular',                durationMin: 180, price: 8000),
        ServiceSubOption(name: 'Ombre – Premium',                durationMin: 180, price: 15000),
      ],
    ),

    // ── 04  Hair Treatment ────────────────────────────────────────────────────
    const SalonService(
      id: '4',
      name: 'Hair Treatment',
      icon: 'healing',
      startingPrice: 200,
      baseDurationMin: 15,
      baseDurationMax: 120,
      description: 'Nourishing & restorative treatments. Starting price for short hair; medium/long cost more.',
      subOptions: [
        ServiceSubOption(name: 'Hair Wash',                   durationMin: 15,  price: 200),
        ServiceSubOption(name: 'Hot Oil Massage',             durationMin: 30,  price: 500),
        ServiceSubOption(name: 'Ginger Treatment',            durationMin: 45,  price: 1000),
        ServiceSubOption(name: 'Onion Treatment',             durationMin: 45,  price: 1000),
        ServiceSubOption(name: 'Organic Protein Treatment',   durationMin: 60,  price: 1200),
        ServiceSubOption(name: 'Smoothing Spa',               durationMin: 60,  price: 1500),
        ServiceSubOption(name: 'Keratin Spa Treatment',       durationMin: 60,  price: 2000),
        ServiceSubOption(name: 'Bond Repair',                 durationMin: 60,  price: 2000),
        ServiceSubOption(name: 'Nano Treatment',              durationMin: 60,  price: 2000),
        ServiceSubOption(name: 'Anti Hair Fall Treatment',    durationMin: 60,  price: 2500),
        ServiceSubOption(name: 'Ozone Treatment',             durationMin: 60,  price: 2500),
        ServiceSubOption(name: 'Ampule Treatment',            durationMin: 60,  price: 2500),
        ServiceSubOption(name: 'Korean Hair Smoothing',       durationMin: 90,  price: 3500),
        ServiceSubOption(name: 'Premium Arabian Treatment',   durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Detox Treatment',             durationMin: 60,  price: 4000),
        ServiceSubOption(name: 'Hair Glossing Treatment',     durationMin: 90,  price: 5000),
        ServiceSubOption(name: 'Brazilian Spa Treatment',     durationMin: 90,  price: 5000),
        ServiceSubOption(name: 'Scalp Reduction',             durationMin: 60,  price: 5000),
        ServiceSubOption(name: 'Premium Turkish Treatment',   durationMin: 90,  price: 6000),
      ],
    ),

    // ── 05  Shine Set ─────────────────────────────────────────────────────────
    const SalonService(
      id: '5',
      name: 'Shine Set',
      icon: 'auto_awesome',
      startingPrice: 7500,
      baseDurationMin: 120,
      baseDurationMax: 240,
      description: 'Premium straightening, smoothing, rebonding & Botox. Select Short / Medium / Long.',
      subOptions: [
        ServiceSubOption(name: 'Hair Smoothing – Short',            durationMin: 120, price: 7500),
        ServiceSubOption(name: 'Hair Smoothing – Medium',           durationMin: 150, price: 10000),
        ServiceSubOption(name: 'Hair Smoothing – Long',             durationMin: 180, price: 12000),
        ServiceSubOption(name: 'Permanent Hair Straight – Short',   durationMin: 120, price: 8000),
        ServiceSubOption(name: 'Permanent Hair Straight – Medium',  durationMin: 150, price: 10000),
        ServiceSubOption(name: 'Permanent Hair Straight – Long',    durationMin: 180, price: 12000),
        ServiceSubOption(name: 'Keratin Treatment – Short',         durationMin: 120, price: 8000),
        ServiceSubOption(name: 'Keratin Treatment – Medium',        durationMin: 150, price: 12000),
        ServiceSubOption(name: 'Keratin Treatment – Long',          durationMin: 180, price: 15000),
        ServiceSubOption(name: 'Hair Shine Rebonding – Short',      durationMin: 120, price: 10000),
        ServiceSubOption(name: 'Hair Shine Rebonding – Medium',     durationMin: 150, price: 12000),
        ServiceSubOption(name: 'Hair Shine Rebonding – Long',       durationMin: 180, price: 15000),
        ServiceSubOption(name: 'Brazilian Botox – Short',           durationMin: 150, price: 12000),
        ServiceSubOption(name: 'Brazilian Botox – Medium',          durationMin: 180, price: 17000),
        ServiceSubOption(name: 'Brazilian Botox – Long',            durationMin: 210, price: 20000),
        ServiceSubOption(name: 'Botox Treatment – Short',           durationMin: 150, price: 12000),
        ServiceSubOption(name: 'Botox Treatment – Medium',          durationMin: 180, price: 18000),
        ServiceSubOption(name: 'Botox Treatment – Long',            durationMin: 210, price: 25000),
        ServiceSubOption(name: "L'oreal Advance Treatment – Short", durationMin: 150, price: 12000),
        ServiceSubOption(name: "L'oreal Advance Treatment – Medium",durationMin: 180, price: 18000),
        ServiceSubOption(name: "L'oreal Advance Treatment – Long",  durationMin: 210, price: 25000),
        ServiceSubOption(name: 'R.P Treatment – Short',             durationMin: 150, price: 12000),
        ServiceSubOption(name: 'R.P Treatment – Medium',            durationMin: 180, price: 18000),
        ServiceSubOption(name: 'R.P Treatment – Long',              durationMin: 210, price: 25000),
        ServiceSubOption(name: 'Hair Omega Treatment – Short',      durationMin: 180, price: 15000),
        ServiceSubOption(name: 'Hair Omega Treatment – Medium',     durationMin: 210, price: 20000),
        ServiceSubOption(name: 'Hair Omega Treatment – Long',       durationMin: 240, price: 25000),
      ],
    ),

    // ── 06  Body Spa ──────────────────────────────────────────────────────────
    const SalonService(
      id: '6',
      name: 'Body Spa',
      icon: 'spa',
      startingPrice: 800,
      baseDurationMin: 30,
      baseDurationMax: 120,
      description: 'Relaxing massage & body spa. Choose by duration (30/45/60 min) or premium package.',
      subOptions: [
        ServiceSubOption(name: 'Oil Base Foot Massage – 30 Min',          durationMin: 30,  price: 800),
        ServiceSubOption(name: 'Oil Base Foot Massage – 45 Min',          durationMin: 45,  price: 1200),
        ServiceSubOption(name: 'Oil Base Foot Massage – 60 Min',          durationMin: 60,  price: 1500),
        ServiceSubOption(name: 'Hot Stone Massage – 30 Min',              durationMin: 30,  price: 1000),
        ServiceSubOption(name: 'Hot Stone Massage – 45 Min',              durationMin: 45,  price: 1500),
        ServiceSubOption(name: 'Hot Stone Massage – 60 Min',              durationMin: 60,  price: 1800),
        ServiceSubOption(name: 'Full Body Spa – 30 Min',                  durationMin: 30,  price: 1500),
        ServiceSubOption(name: 'Full Body Spa – 45 Min',                  durationMin: 45,  price: 1800),
        ServiceSubOption(name: 'Full Body Spa – 60 Min',                  durationMin: 60,  price: 2200),
        ServiceSubOption(name: 'Hot Oil Massage Full Body – 30 Min',      durationMin: 30,  price: 1800),
        ServiceSubOption(name: 'Hot Oil Massage Full Body – 45 Min',      durationMin: 45,  price: 2200),
        ServiceSubOption(name: 'Hot Oil Massage Full Body – 60 Min',      durationMin: 60,  price: 2500),
        ServiceSubOption(name: 'Pain Relief Hot Stone Massage – 30 Min',  durationMin: 30,  price: 2000),
        ServiceSubOption(name: 'Pain Relief Hot Stone Massage – 45 Min',  durationMin: 45,  price: 2200),
        ServiceSubOption(name: 'Pain Relief Hot Stone Massage – 60 Min',  durationMin: 60,  price: 2500),
        ServiceSubOption(name: 'Classic Body Spa',                        durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Classic Oil Body Spa',                    durationMin: 90,  price: 5000),
        ServiceSubOption(name: 'Hot Stone with Oil Body Spa',             durationMin: 90,  price: 6000),
        ServiceSubOption(name: 'Relax & Rejuvenate Spa',                  durationMin: 120, price: 8000),
        ServiceSubOption(name: 'Noor Signature Body Spa',                 durationMin: 120, price: 10000),
      ],
    ),

    // ── 07  Facial ────────────────────────────────────────────────────────────
    const SalonService(
      id: '7',
      name: 'Facial',
      icon: 'face_retouching_natural',
      startingPrice: 1000,
      baseDurationMin: 45,
      baseDurationMax: 90,
      description: 'Basic to premium facial treatments for every skin type.',
      subOptions: [
        ServiceSubOption(name: 'Deep Purifying Facial',        durationMin: 45, price: 1000),
        ServiceSubOption(name: 'Fruit Facial',                 durationMin: 45, price: 1500),
        ServiceSubOption(name: 'Whitening Facial',             durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Vitamin-C Facial',             durationMin: 45, price: 2000),
        ServiceSubOption(name: 'D-Tan Facial',                 durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Bright & Shine Facial',        durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Facial with Glow Boost Pack',  durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Ayurvedic Facial',             durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Red Rose Facial',              durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Pink Glossy Facial',           durationMin: 45, price: 2000),
        ServiceSubOption(name: '24 Caret Foil Gold Facial',    durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Diamond Silk Facial',          durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Elegant Pearl Facial',         durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Clarify Ozone Facial',         durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Clove Acne Facial',            durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Hydro Jelly Facial',           durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Lavender Extract Facial',      durationMin: 60, price: 2500),
        ServiceSubOption(name: 'Therma Herb Facial',           durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Blue Lotus Facial with Ice',   durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Vampire/Skin Revamp Facial',   durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Collagen Facial',              durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Retirant Retinol Facial',      durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Black Diamond Facial',         durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Hydra Facial',                 durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Oxygen Facial',                durationMin: 60, price: 3500),
        ServiceSubOption(name: 'Wine Facial',                  durationMin: 60, price: 3500),
        ServiceSubOption(name: 'Bio Hydra Facial',             durationMin: 60, price: 3500),
        ServiceSubOption(name: 'Face Lifting Facial',          durationMin: 75, price: 3500),
        ServiceSubOption(name: 'Cupping Facial',               durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Ice-Crystal Facial',           durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Velvet Glam Facial',           durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Hydra Boost Facial',           durationMin: 75, price: 4500),
        ServiceSubOption(name: 'Skin Peel-off Facial',         durationMin: 75, price: 4500),
        ServiceSubOption(name: 'Detox Facial',                 durationMin: 90, price: 5000),
        ServiceSubOption(name: 'Advance Bio-Hydra Facial',     durationMin: 90, price: 5000),
        ServiceSubOption(name: 'Korean Glass Skin Facial',     durationMin: 90, price: 5000),
      ],
    ),

    // ── 08  Glow Polish ───────────────────────────────────────────────────────
    const SalonService(
      id: '8',
      name: 'Glow Polish',
      icon: 'auto_fix_high',
      startingPrice: 500,
      baseDurationMin: 20,
      baseDurationMax: 60,
      description: 'Brightening glow polish for face, body areas & full body.',
      subOptions: [
        ServiceSubOption(name: 'Back Massage',                           durationMin: 20, price: 500),
        ServiceSubOption(name: 'Back Facial',                            durationMin: 30, price: 1000),
        ServiceSubOption(name: 'Bikini Brightening with Glow Polish',    durationMin: 30, price: 1000),
        ServiceSubOption(name: 'Neck Brightening with Glow Polish',      durationMin: 20, price: 1000),
        ServiceSubOption(name: 'Underarm Brightening with Glow Polish',  durationMin: 20, price: 1000),
        ServiceSubOption(name: 'Full Face Polish',                       durationMin: 30, price: 1000),
        ServiceSubOption(name: 'Half Hand & Leg Polish',                 durationMin: 30, price: 1200),
        ServiceSubOption(name: 'Full Hand & Leg Polish',                 durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Full Back Polish',                       durationMin: 30, price: 2000),
        ServiceSubOption(name: 'Full Body Glow Polish',                  durationMin: 60, price: 6000),
      ],
    ),

    // ── 09  Waxing ────────────────────────────────────────────────────────────
    const SalonService(
      id: '9',
      name: 'Waxing',
      icon: 'cleaning_services',
      startingPrice: 200,
      baseDurationMin: 10,
      baseDurationMax: 90,
      description: 'Professional waxing for eyebrows, face, arms, legs & full body.',
      subOptions: [
        ServiceSubOption(name: 'Eye Brow Wax',          durationMin: 10, price: 200),
        ServiceSubOption(name: 'Upper Lip Wax',         durationMin: 10, price: 200),
        ServiceSubOption(name: 'Chin Wax',              durationMin: 10, price: 200),
        ServiceSubOption(name: 'Under Arm Wax',         durationMin: 15, price: 600),
        ServiceSubOption(name: 'Half Leg Wax',          durationMin: 20, price: 800),
        ServiceSubOption(name: 'Half Hand Wax',         durationMin: 20, price: 800),
        ServiceSubOption(name: 'Full Face Wax',         durationMin: 20, price: 1000),
        ServiceSubOption(name: 'Full Leg Wax',          durationMin: 30, price: 1200),
        ServiceSubOption(name: 'Full Hand Wax',         durationMin: 30, price: 1200),
        ServiceSubOption(name: 'Bikini Wax',            durationMin: 30, price: 1500),
        ServiceSubOption(name: 'Brazilian with Bikini', durationMin: 45, price: 2000),
        ServiceSubOption(name: 'Full Body with Bikini', durationMin: 90, price: 5000),
      ],
    ),

    // ── 10  Pedicure & Manicure ───────────────────────────────────────────────
    const SalonService(
      id: '10',
      name: 'Pedicure & Manicure',
      icon: 'back_hand',
      startingPrice: 1500,
      baseDurationMin: 60,
      baseDurationMax: 90,
      description: 'Classic to luxury pedicure and manicure treatments.',
      subOptions: [
        ServiceSubOption(name: 'Classic Pedi/Mani',              durationMin: 60, price: 1500),
        ServiceSubOption(name: 'Beetroot Pedi/Mani',             durationMin: 60, price: 2000),
        ServiceSubOption(name: 'Whitening Pedi & Mani',          durationMin: 60, price: 2000),
        ServiceSubOption(name: 'Crystal Pedi & Mani',            durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Hot Stone Pedi/Mani',            durationMin: 60, price: 3000),
        ServiceSubOption(name: 'D-light Pedi/Mani',              durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Russian Paraffin Pedi/Mani',     durationMin: 75, price: 3500),
        ServiceSubOption(name: 'Turkish Pedi/Mani',              durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Hydra Boost Premium Pedi/Mani',  durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Premium Red Rose Pedi/Mani',     durationMin: 75, price: 4000),
        ServiceSubOption(name: 'Premium Arabic Pedi/Mani',       durationMin: 90, price: 5000),
      ],
    ),

    // ── 11  Nail Extension ────────────────────────────────────────────────────
    const SalonService(
      id: '11',
      name: 'Nail Extension',
      icon: 'extension',
      startingPrice: 1500,
      baseDurationMin: 60,
      baseDurationMax: 120,
      description: 'Gel, acrylic & powder nail extensions with optional add-ons (both hands).',
      subOptions: [
        ServiceSubOption(name: 'Nail Extension Only (2 hand)',                 durationMin: 60,  price: 1500),
        ServiceSubOption(name: 'One Color Gel Extension',                      durationMin: 60,  price: 2000),
        ServiceSubOption(name: 'French Nail Extension (2 Hand)',               durationMin: 60,  price: 2000),
        ServiceSubOption(name: 'Poly Acrylic Gel Extension (2 hand)',          durationMin: 90,  price: 3000),
        ServiceSubOption(name: 'Magnetic Gel Extension (2 hand)',              durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Gel with Shimmer/Glitter/Stone (2 hand)',      durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Acrylic Powder Extension (2 hand)',            durationMin: 90,  price: 4000),
        ServiceSubOption(name: 'Add-on: Foil/Glitter/Shimmer (2 Hand)',        durationMin: 20,  price: 500),
        ServiceSubOption(name: 'Add-on: Flower/Stone/Pearl (2 Hand)',          durationMin: 30,  price: 2000),
        ServiceSubOption(name: 'Add-on: Disco/Blooming/Marble/Ombre (2 Hand)', durationMin: 30,  price: 2000),
      ],
    ),

    // ── 12  Eye Lash ──────────────────────────────────────────────────────────
    const SalonService(
      id: '12',
      name: 'Eye Lash',
      icon: 'visibility',
      startingPrice: 2000,
      baseDurationMin: 30,
      baseDurationMax: 90,
      description: 'Lash extensions, lifting, brow micro-blending & skin spot removal.',
      subOptions: [
        ServiceSubOption(name: 'Mole Remove',              durationMin: 30, price: 2000),
        ServiceSubOption(name: 'Freckles Remove',          durationMin: 30, price: 2000),
        ServiceSubOption(name: 'Volume Eye Lash',          durationMin: 60, price: 3000),
        ServiceSubOption(name: 'Lash Lifting',             durationMin: 45, price: 3000),
        ServiceSubOption(name: 'Cat Eye/Doll Eye Lash',    durationMin: 60, price: 3500),
        ServiceSubOption(name: 'Wispy Eye',                durationMin: 60, price: 4000),
        ServiceSubOption(name: 'Eye Brow Micro Blending',  durationMin: 60, price: 4000),
        ServiceSubOption(name: 'Hybrid Eye Lash',          durationMin: 75, price: 4200),
        ServiceSubOption(name: 'Mega Volume',              durationMin: 90, price: 5000),
      ],
    ),

    // ── 13  Henna (Mehedi) ────────────────────────────────────────────────────
    const SalonService(
      id: '13',
      name: 'Henna (Mehedi)',
      icon: 'brush_outlined',
      startingPrice: 600,
      baseDurationMin: 45,
      baseDurationMax: 120,
      description: 'Traditional henna designs for weddings and occasions.',
      subOptions: [
        ServiceSubOption(name: 'One Hand, One Side',    durationMin: 45,  price: 600),
        ServiceSubOption(name: 'Both Hands, One Side',  durationMin: 75,  price: 1200),
        ServiceSubOption(name: 'One Hand, Both Sides',  durationMin: 75,  price: 1200),
        ServiceSubOption(name: 'Both Hands, Both Sides',durationMin: 120, price: 2400),
      ],
    ),

    // ── 14  Makeup ────────────────────────────────────────────────────────────
    const SalonService(
      id: '14',
      name: 'Makeup',
      icon: 'face',
      startingPrice: 3000,
      baseDurationMin: 60,
      baseDurationMax: 120,
      description: 'Party & occasion makeup packages from simple to premium glam looks.',
      subOptions: [
        ServiceSubOption(name: 'Package 1 – Simple Look (Sharee Draping + Normal Hair)',   durationMin: 60,  price: 3000),
        ServiceSubOption(name: 'Package 2 – Elegant Look (Classy Hair + Jewelry)',         durationMin: 90,  price: 5000),
        ServiceSubOption(name: 'Package 3 – Gorgeous Glam (Glitter Eye + Party Hair)',     durationMin: 90,  price: 8000),
        ServiceSubOption(name: 'Package 4 – Premium Glam (High End + Customized Eye)',     durationMin: 120, price: 10000),
      ],
    ),

    // ── 15  Bridal Package ────────────────────────────────────────────────────
    const SalonService(
      id: '15',
      name: 'Bridal Package',
      icon: 'favorite',
      startingPrice: 8000,
      baseDurationMin: 120,
      baseDurationMax: 300,
      description: 'Complete bridal makeup & hair for engagement and wedding day.',
      subOptions: [
        ServiceSubOption(name: 'Package 1 – Engagement/Akhd (Matte, 8000)',    durationMin: 120, price: 8000),
        ServiceSubOption(name: 'Package 2 – Engagement/Akhd (Glowy, 15000)',   durationMin: 150, price: 15000),
        ServiceSubOption(name: 'Package 3 – Wedding/Reception (20000)',         durationMin: 180, price: 20000),
        ServiceSubOption(name: 'Package 4 – Pakistani Inspired Wedding (25000)',durationMin: 210, price: 25000),
        ServiceSubOption(name: 'Package 5 – Luxury Wedding (30000)',            durationMin: 300, price: 30000),
      ],
    ),

    // ── 16  Pre-Wedding Package ───────────────────────────────────────────────
    const SalonService(
      id: '16',
      name: 'Pre-Wedding Package',
      icon: 'diamond',
      startingPrice: 5000,
      baseDurationMin: 120,
      baseDurationMax: 240,
      description: 'Full pre-bridal grooming packages to prepare you for your special day.',
      subOptions: [
        ServiceSubOption(name: 'Package 1 – Petal Touch Bridal Care',     durationMin: 120, price: 5000),
        ServiceSubOption(name: 'Package 2 – Bride to be Glam Ritual',     durationMin: 180, price: 10000),
        ServiceSubOption(name: 'Package 3 – Signature Luxury Bridal',     durationMin: 240, price: 15000),
      ],
    ),

    // ── 17  Noor Package ──────────────────────────────────────────────────────
    const SalonService(
      id: '17',
      name: 'Noor Package',
      icon: 'star',
      startingPrice: 2500,
      baseDurationMin: 90,
      baseDurationMax: 180,
      description: "Noor's exclusive value packages combining multiple services.",
      subOptions: [
        ServiceSubOption(name: 'Noor Package 1 – Summer Shine (2500)',  durationMin: 90,  price: 2500),
        ServiceSubOption(name: 'Noor Package 2 – Red Rose (3000)',      durationMin: 120, price: 3000),
        ServiceSubOption(name: 'Noor Package 3 – Glow Boost (3500)',    durationMin: 120, price: 3500),
        ServiceSubOption(name: 'Noor Package 4 – Protein Glow (4000)',  durationMin: 150, price: 4000),
        ServiceSubOption(name: 'Noor Package 5 – Hydra Luxury (5000)',  durationMin: 180, price: 5000),
      ],
    ),

    // ── 18  Happy Hour Package ────────────────────────────────────────────────
    const SalonService(
      id: '18',
      name: 'Happy Hour Package',
      icon: 'local_offer',
      startingPrice: 3000,
      baseDurationMin: 90,
      baseDurationMax: 150,
      description: 'Special discounted packages. Offer prices shown below.',
      subOptions: [
        ServiceSubOption(name: 'Package 1 – Classic Pedi/Mani + Back Massage + Fruit Facial + Oil Massage + Shampoo (Offer 3000)',                               durationMin: 90,  price: 3000),
        ServiceSubOption(name: 'Package 2 – Full Hand Wax + Full Leg Wax + Double Cleansing Facial + Oil Massage + Shampoo + Massage Pedi/Mani (Offer 4000)',    durationMin: 120, price: 4000),
        ServiceSubOption(name: 'Package 3 – Spa Facial + Classic Pedi/Mani + Full Hand & Leg Wax + Shampoo + Hot Oil Massage (Scalp) + Threading (Offer 4000)', durationMin: 150, price: 4000),
      ],
    ),

    // ── 19  Special Package ───────────────────────────────────────────────────
    const SalonService(
      id: '19',
      name: 'Special Package',
      icon: 'card_giftcard',
      startingPrice: 1500,
      baseDurationMin: 60,
      baseDurationMax: 150,
      description: 'Special packages for kids, teens, students & employees. ID required for student/employee offers.',
      subOptions: [
        ServiceSubOption(name: 'Princess Package – Kids (Hair Cut + Pedicure + Oil Massage)',  durationMin: 60,  price: 1500),
        ServiceSubOption(name: 'Teenage Package – Wax + Face Cleansing + Pedi & Mani',        durationMin: 60,  price: 1500),
        ServiceSubOption(name: 'Employee Package – Hair Spa + Cut + Facial + Wax + Threading',durationMin: 150, price: 4500),
      ],
    ),
  ];
}
