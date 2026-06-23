import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';
import '../../utils/colors.dart';
import '../../utils/nav.dart';
import '../../widgets/custom_button.dart';

/// Simplified booking: pick date & time → confirm with price.
/// Stylist is assigned by the salon, no user choice required.
class BookingScreen extends StatefulWidget {
  final SalonService? preselectedService;
  final ServiceSubOption? preselectedSubOption;

  const BookingScreen({
    super.key,
    this.preselectedService,
    this.preselectedSubOption,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // step 0 = service+option selection (only when not preselected)
  // step 1 = date & time
  // step 2 = confirm
  late int _step;

  SalonService? _service;
  ServiceSubOption? _subOption;
  ServiceVariant? _variant;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String? _time;
  bool _isBooked = false;
  late ConfettiController _confettiController;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = widget.preselectedService;
    _subOption = widget.preselectedSubOption;
    _step = (_service != null) ? 1 : 0;
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  int get _duration => _subOption?.durationMin ?? _service?.baseDurationMin ?? 60;
  int get _price    => _variant?.price ?? _subOption?.price ?? _service?.startingPrice ?? 0;

  String get _optLabel {
    final base = _subOption?.name ?? _service?.name ?? '';
    return _variant != null ? '$base - ${_variant!.label}' : base;
  }

  List<String> get _timeSlots =>
      context.read<BookingService>().getAvailableTimeSlots(date: _date, durationMinutes: _duration, openTime: '11:00');

  bool get _needsVariant => _subOption != null && _subOption!.variants.isNotEmpty && _variant == null;

  bool get _canProceed {
    if (_step == 0) return _service != null;
    if (_step == 1) return _time != null && !_needsVariant;
    return true;
  }

  Future<void> _confirm() async {
    final auth    = context.read<AuthService>();
    final booking = context.read<BookingService>();
    if (_service == null || _time == null) return;

    final result = await booking.createBooking(
      customerId:      auth.currentUser?.id ?? 'guest',
      stylistId:       '',   // assigned by salon
      serviceId:       _service!.id,
      serviceName:     _optLabel,
      price:           _price,
      bookingDate:     _date,
      startTime:       _time!,
      durationMinutes: _duration,
      notes: [
        if (_subOption != null) _subOption!.name,
        if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
      ].join(' — ').isEmpty ? null : [
        if (_subOption != null) _subOption!.name,
        if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
      ].join(' — '),
    );

    if (!mounted) return;

    if (result != null) {
      try {
        final dateStr = DateFormat('MMM d, yyyy').format(_date);
        await NotificationService.instance.showBookingConfirmation(
          serviceName: _service!.name,
          date: dateStr,
          time: _time!,
        );
      } catch (_) {}
      if (!mounted) return;
      setState(() => _isBooked = true);
      _confettiController.play();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(booking.error ?? 'Booking failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _confettiCannon({required Alignment alignment, required double angle}) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: angle,
        numberOfParticles: 18,
        maxBlastForce: 30,
        minBlastForce: 10,
        emissionFrequency: 0.04,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          Color(0xFFD4AF37),
          Color(0xFFFF6B9D),
          Color(0xFF74B9FF),
          Color(0xFFFD79A8),
          Color(0xFF55EFC4),
          Color(0xFFFDCB6E),
          Color(0xFFE17055),
          Color(0xFFA29BFE),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isBooked) {
      return Scaffold(
        body: Stack(
          children: [
            _buildSuccessView(),
            _confettiCannon(alignment: Alignment.topLeft, angle: pi / 3.5),
            _confettiCannon(alignment: Alignment.topRight, angle: pi - pi / 3.5),
            _confettiCannon(alignment: Alignment.topCenter, angle: pi / 2),
          ],
        ),
      );
    }

    final stepCount = _service != null && widget.preselectedService != null ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        // Explicit, safe back: returns to the previous screen (or Home),
        // never to the login screen. Keeps the user logged in.
        leading: BackButton(onPressed: () => safeBack(context)),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: List.generate(stepCount, (i) {
                final active = i <= (_service != null ? _step - 1 : _step);
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < stepCount - 1 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(_step),
              padding: const EdgeInsets.all(20),
              child: _step == 0
                  ? _buildServiceStep()
                  : _step == 1
                      ? _buildDateTimeStep()
                      : _buildConfirmStep(),
            ),
          ),

          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Success view (after booking confirmed) ───────────────────────────────

  Widget _buildSuccessView() {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(_date);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 52),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80),
            ),
            const SizedBox(height: 22),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your appointment is all set. See you soon!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _row('Service', _subOption?.name ?? _service?.name ?? '—'),
                  _row('Date', dateStr),
                  _row('Time', _time ?? '—'),
                  _row('Duration', '$_duration min'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Price',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('৳$_price',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Any mode of payment accepted at salon',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Done',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 0: Service & sub-option ─────────────────────────────────────────

  Widget _buildServiceStep() {
    final services = context.read<BookingService>().services;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...services.map((svc) {
          final selected = _service?.id == svc.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() { _service = svc; _subOption = null; _variant = null; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder, width: selected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(svc.iconData, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(svc.name, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textPrimary)),
                          Text('${svc.subOptions.length} options · From ৳${svc.startingPrice}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_service != null && _service!.subOptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Choose a Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ..._service!.subOptions.map((opt) {
            final sel = _subOption?.name == opt.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() { _subOption = opt; _variant = null; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.cardBorder, width: sel ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.name, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                            Text('${opt.durationMin} min', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text('৳${opt.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      if (sel) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: AppColors.primary, size: 18)],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Step 1: Date & time ──────────────────────────────────────────────────

  Widget _buildSizePicker() {
    final opt = _subOption!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opt.variants.map((v) {
            final sel = _variant?.label == v.label;
            return GestureDetector(
              onTap: () => setState(() => _variant = v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.cardBorder, width: sel ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(v.label, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? AppColors.primary : AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text('\u09F3${v.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service summary chip
        if (_service != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(_service!.iconData, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_service!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (_subOption != null)
                        Text(_subOption!.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text('৳$_price', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),

        if (_subOption != null && _subOption!.variants.isNotEmpty) _buildSizePicker(),
        const Text('Select Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Compact horizontal date strip — next 60 days
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 60,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = DateTime.now().add(Duration(days: i + 1));
              final sel = isSameDay(_date, d);
              return InkWell(
                onTap: () => setState(() { _date = d; _time = null; }),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 54,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.cardBorder,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(d).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.black : AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: sel ? Colors.black : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(d),
                        style: TextStyle(
                          fontSize: 10,
                          color: sel ? Colors.black87 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Selected date display
        if (true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_date),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
                ),
              ],
            ),
          ),
        const Text('Select Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _timeSlots.map((slot) {
            final sel = _time == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: sel,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: sel ? AppColors.secondary : AppColors.textPrimary),
              onSelected: (_) => setState(() => _time = slot),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _notesCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Confirm ──────────────────────────────────────────────────────

  Widget _buildConfirmStep() {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(_date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              _row('Service',  _service?.name ?? '—'),
              if (_subOption != null) _row('Package', _optLabel),
              _row('Duration', '$_duration min'),
              _row('Date',     dateStr),
              _row('Time',     _time ?? '—'),
              if (_notesCtrl.text.trim().isNotEmpty)
                _row('Notes', _notesCtrl.text.trim()),
              const Divider(height: 24),
              // Price highlight
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Price', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('৳$_price', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Any mode of payment accepted at salon', style: TextStyle(fontSize: 13))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  // ── Bottom bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _step == 2;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: CustomButton(
                label: 'Back',
                variant: ButtonVariant.outline,
                onPressed: () => setState(() => _step--),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: CustomButton(
              label: isLast ? 'Confirm Booking' : 'Continue',
              isLoading: isLast && context.watch<BookingService>().isLoading,
              onPressed: _canProceed
                  ? (isLast ? _confirm : () => setState(() => _step++))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
