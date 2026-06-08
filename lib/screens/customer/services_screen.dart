import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../services/booking_service.dart';
import '../../utils/colors.dart';
import '../../widgets/service_card.dart';
import 'booking_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

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
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
          if (booking.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (services.isEmpty)
            const Expanded(
              child: Center(child: Text('No services found')),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ServiceCard(
                      service: services[index],
                      onTap: () => _navigateToBooking(context, services[index]),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToBooking(BuildContext context, SalonService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(preselectedService: service),
      ),
    );
  }
}
