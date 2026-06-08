import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/service.dart';
import '../../models/stylist.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stylist_card.dart';

class BookingScreen extends StatefulWidget {
  final SalonService? preselectedService;

  const BookingScreen({super.key, this.preselectedService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  SalonService? _selectedService;
  int _selectedDuration = 60;
  int? _customDuration;
  Stylist? _selectedStylist;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final _notesController = TextEditingController();
  final _customDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService;
    if (_selectedService != null) {
      _selectedDuration = _selectedService!.baseDurationMin;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  int get _effectiveDuration =>
      _selectedDuration == -1 ? (_customDuration ?? 60) : _selectedDuration;

  List<Stylist> get _availableStylists {
    if (_selectedService == null) return [];
    return context
        .read<BookingService>()
        .getStylistsForService(_selectedService!.name);
  }

  List<String> get _timeSlots {
    return context.read<BookingService>().getAvailableTimeSlots(
          date: _selectedDate,
          durationMinutes: _effectiveDuration,
        );
  }

  Future<void> _confirmBooking() async {
    final auth = context.read<AuthService>();
    final bookingService = context.read<BookingService>();

    if (auth.currentUser == null ||
        _selectedService == null ||
        _selectedStylist == null ||
        _selectedTime == null) {
      return;
    }

    final booking = await bookingService.createBooking(
      customerId: auth.currentUser!.id,
      stylistId: _selectedStylist!.id,
      serviceId: _selectedService!.id,
      bookingDate: _selectedDate,
      startTime: _selectedTime!,
      durationMinutes: _effectiveDuration,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (booking != null) {
      final dateStr = DateFormat('MMM d, yyyy').format(_selectedDate);
      await NotificationService.instance.showBookingConfirmation(
        serviceName: _selectedService!.name,
        date: dateStr,
        time: _selectedTime!,
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('Booking Confirmed!'),
            ],
          ),
          content: Text(
            'Your ${_selectedService!.name} appointment with ${_selectedStylist!.name} '
            'on $dateStr at $_selectedTime has been booked.\n\n'
            'Payment: Cash at salon',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingService.error ?? 'Booking failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _canContinue() ? _nextStep : null,
              onStepCancel: _currentStep > 0 ? _prevStep : null,
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              steps: [
                Step(
                  title: const Text('Service'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: _buildServiceStep(booking),
                ),
                Step(
                  title: const Text('Duration'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: _buildDurationStep(),
                ),
                Step(
                  title: const Text('Stylist'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  content: _buildStylistStep(),
                ),
                Step(
                  title: const Text('Date & Time'),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                  content: _buildDateTimeStep(),
                ),
                Step(
                  title: const Text('Confirm'),
                  isActive: _currentStep >= 4,
                  content: _buildConfirmStep(),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: i <= _currentStep ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceStep(BookingService booking) {
    return Column(
      children: booking.services.map((service) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(service.iconData, color: AppColors.primary),
            title: Text(service.name),
            subtitle: Text('${service.baseDurationMin}–${service.baseDurationMax} min'),
            selected: _selectedService?.id == service.id,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () => setState(() {
              _selectedService = service;
              _selectedDuration = service.baseDurationMin;
              _selectedStylist = null;
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationStep() {
    const options = [
      (30, '30 minutes'),
      (60, '1 hour'),
      (120, '2 hours'),
      (-1, 'Custom'),
    ];

    return Column(
      children: [
        ...options.map((opt) {
          return RadioListTile<int>(
            title: Text(opt.$2),
            value: opt.$1,
            groupValue: _selectedDuration,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _selectedDuration = v!),
          );
        }),
        if (_selectedDuration == -1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _customDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Custom duration (minutes)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => _customDuration = int.tryParse(v)),
            ),
          ),
      ],
    );
  }

  Widget _buildStylistStep() {
    final stylists = _availableStylists;
    if (stylists.isEmpty) {
      return const Text('No stylists available for this service.');
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stylists.length,
        itemBuilder: (context, index) {
          final stylist = stylists[index];
          return StylistCard(
            stylist: stylist,
            isSelected: _selectedStylist?.id == stylist.id,
            onTap: () => setState(() => _selectedStylist = stylist),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selected, _) =>
              setState(() => _selectedDate = selected),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Available Times', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((slot) {
            final isSelected = _selectedTime == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.secondary : AppColors.textPrimary,
              ),
              onSelected: (_) => setState(() => _selectedTime = slot),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    if (_selectedService == null || _selectedStylist == null || _selectedTime == null) {
      return const Text('Please complete all previous steps.');
    }

    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Service', _selectedService!.name),
          _summaryRow('Duration', '$_effectiveDuration min'),
          _summaryRow('Stylist', _selectedStylist!.name),
          _summaryRow('Date', dateStr),
          _summaryRow('Time', _selectedTime!),
          if (_notesController.text.isNotEmpty)
            _summaryRow('Notes', _notesController.text),
          const Divider(),
          const Row(
            children: [
              Icon(Icons.payments_outlined, size: 18, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Pay cash at the salon', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                label: 'Back',
                variant: ButtonVariant.outline,
                onPressed: _prevStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomButton(
              label: _currentStep == 4 ? 'Confirm Booking' : 'Continue',
              isLoading: _currentStep == 4 && context.watch<BookingService>().isLoading,
              onPressed: _canContinue()
                  ? (_currentStep == 4 ? _confirmBooking : _nextStep)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedDuration != -1 ||
            (_customDuration != null && _customDuration! > 0);
      case 2:
        return _selectedStylist != null;
      case 3:
        return _selectedTime != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }
}
