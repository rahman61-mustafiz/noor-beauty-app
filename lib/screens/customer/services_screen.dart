import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../services/booking_service.dart';
import '../../utils/colors.dart';
import '../../widgets/service_card.dart';
import 'booking_screen.dart';

class ServicesScreen extends StatefulWidget {
  final String categoryFilter;

  const ServicesScreen({super.key, this.categoryFilter = ''});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';
  late String _activeCategory;

  static const _cats = [
    {'label': 'All',    'filter': ''},
    {'label': 'Hair',   'filter': 'hair'},
    {'label': 'Nails',  'filter': 'nails'},
    {'label': 'Facial', 'filter': 'facial'},
    {'label': 'Bridal', 'filter': 'bridal'},
    {'label': 'Spa',    'filter': 'spa'},
  ];

  @override
  void initState() {
    super.initState();
    _activeCategory = widget.categoryFilter;
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryFilter != widget.categoryFilter) {
      setState(() => _activeCategory = widget.categoryFilter);
    }
  }

  bool _matchesCategory(SalonService s) {
    final filter = _activeCategory;
    if (filter.isEmpty) return true;
    final n = s.name.toLowerCase();
    switch (filter) {
      case 'hair':   return n.contains('hair') || n.contains('styling') || n.contains('color');
      case 'nails':  return n.contains('mani') || n.contains('nail');
      case 'facial': return n.contains('facial');
      case 'bridal': return n.contains('bridal') || n.contains('mehedi');
      case 'spa':    return n.contains('spa') || n.contains('wax');
      default:       return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();
    final services = booking.services.where((s) {
      final matchSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch && _matchesCategory(s);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final filter = cat['filter']!;
                final selected = _activeCategory == filter;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.cardBorder,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => setState(() => _activeCategory = filter),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          cat['label']!,
                          style: TextStyle(
                            color: selected ? AppColors.secondary : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          if (booking.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (services.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text('No services found',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ServiceCard(
                      service: services[index],
                      onTap: () => _navigateToBooking(context, services[index], null),
                      onSubOptionBook: (opt) => _navigateToBooking(context, services[index], opt),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToBooking(BuildContext context, SalonService service, ServiceSubOption? opt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(preselectedService: service, preselectedSubOption: opt),
      ),
    );
  }
}
