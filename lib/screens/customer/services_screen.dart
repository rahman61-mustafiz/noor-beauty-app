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

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();
    final services = booking.services.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: Column(
        children: [
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

          const SizedBox(height: 4),

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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