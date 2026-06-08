import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/colors.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _statusFilter;
  String? _stylistFilter;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    await context.read<BookingService>().loadAdminBookings(
          status: _statusFilter,
          stylistId: _stylistFilter,
        );
  }

  Future<void> _updateStatus(Booking booking, String status) async {
    final notesController = TextEditingController(text: booking.notesAdmin);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${status[0].toUpperCase()}${status.substring(1)} Booking'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Admin Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await context.read<BookingService>().adminUpdateBooking(booking.id, {
      'status': status,
      'notesAdmin': notesController.text.trim(),
    });
    notesController.dispose();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) {
                    setState(() => _statusFilter = v);
                    _loadBookings();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadBookings,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          tabs: const [
            Tab(text: 'List View'),
            Tab(text: 'Calendar'),
          ],
        ),
        Expanded(
          child: booking.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(booking.bookings),
                    _buildCalendar(booking.bookings),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _statusColor(b.status),
              child: Text(
                b.customerName?.isNotEmpty == true
                    ? b.customerName![0].toUpperCase()
                    : '?',
                style: const TextStyle(color: AppColors.secondary),
              ),
            ),
            title: Text(b.customerName ?? 'Customer'),
            subtitle: Text(
              '${b.serviceName ?? 'Service'} • ${DateFormat('MMM d').format(b.bookingDate)} ${b.startTime}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Stylist', b.stylistName ?? b.stylistId),
                    _detailRow('Status', b.status.toUpperCase()),
                    _detailRow('Duration', '${b.durationMinutes} min'),
                    if (b.notesCustomer != null)
                      _detailRow('Customer Notes', b.notesCustomer!),
                    if (b.notesAdmin != null)
                      _detailRow('Admin Notes', b.notesAdmin!),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (b.isPending)
                          _actionChip('Confirm', AppColors.success,
                              () => _updateStatus(b, 'confirmed')),
                        if (!b.isCompleted && !b.isCancelled)
                          _actionChip('Complete', AppColors.teal,
                              () => _updateStatus(b, 'completed')),
                        if (!b.isCancelled)
                          _actionChip('Cancel', AppColors.error,
                              () => _updateStatus(b, 'cancelled')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(List<Booking> bookings) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      focusedDay: _focusedDay,
      onPageChanged: (day) => setState(() => _focusedDay = day),
      eventLoader: (day) =>
          bookings.where((b) => isSameDay(b.bookingDate, day)).toList(),
      calendarStyle: const CalendarStyle(
        markerDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selected, _) {
        final dayBookings = bookings
            .where((b) => isSameDay(b.bookingDate, selected))
            .toList();
        if (dayBookings.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => ListView(
              children: dayBookings
                  .map((b) => ListTile(
                        title: Text(b.customerName ?? 'Customer'),
                        subtitle: Text(
                          '${b.serviceName} at ${b.startTime}',
                        ),
                        trailing: Chip(label: Text(b.status)),
                      ))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _actionChip(String label, Color color, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      onPressed: onTap,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return AppColors.teal;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}
