import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';
import '../../utils/colors.dart';
import '../../widgets/booking_card.dart';
import 'review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }

  Future<void> _loadBookings() async {
    final auth = context.read<AuthService>();
    if (auth.currentUser != null) {
      await context
          .read<BookingService>()
          .loadCustomerBookings(auth.currentUser!.id);
    }
  }

  List<Booking> _filteredBookings(List<Booking> bookings) {
    if (_statusFilter == 'all') return bookings;
    return bookings.where((b) => b.status == _statusFilter).toList();
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel your ${booking.serviceName ?? 'appointment'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await context.read<BookingService>().cancelBooking(booking.id);
    if (!mounted) return;

    if (success) {
      await NotificationService.instance.showCancellationNotification(
        serviceName: booking.serviceName ?? 'appointment',
        date: DateFormat('MMM d').format(booking.bookingDate),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    }
  }

  Future<void> _rescheduleBooking(Booking booking) async {
    DateTime selectedDate = booking.bookingDate;
    String? selectedTime = booking.startTime;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final slots = context.read<BookingService>().getAvailableTimeSlots(
                date: selectedDate,
                durationMinutes: booking.durationMinutes,
              );

          return AlertDialog(
            title: const Text('Reschedule'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: selectedDate,
                    selectedDayPredicate: (d) => isSameDay(selectedDate, d),
                    onDaySelected: (d, _) =>
                        setDialogState(() => selectedDate = d),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    decoration: const InputDecoration(labelText: 'Time'),
                    items: slots
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedTime = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: selectedTime != null
                    ? () => Navigator.pop(ctx, true)
                    : null,
                child: const Text('Reschedule'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true || selectedTime == null) return;

    final success = await context.read<BookingService>().rescheduleBooking(
          bookingId: booking.id,
          newDate: selectedDate,
          newStartTime: selectedTime!,
          durationMinutes: booking.durationMinutes,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Booking rescheduled' : 'Reschedule failed'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();
    final bookings = _filteredBookings(booking.bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      body: booking.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildListView(bookings),
    );
  }

  Widget _buildListView(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.divider),
            SizedBox(height: 16),
            Text('No bookings yet', style: TextStyle(fontSize: 18)),
            Text('Book your first appointment!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return BookingCard(
            booking: b,
            onCancel: () => _cancelBooking(b),
            onReschedule: () => _rescheduleBooking(b),
            onReview: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewScreen(booking: b),
              ),
            ),
          );
        },
      ),
    );
  }

}
