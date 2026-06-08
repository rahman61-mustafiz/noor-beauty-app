import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../utils/app_theme.dart';
import '../utils/colors.dart';

class BookingCard extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onReview;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.onReview,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _hovered = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppTheme.hoverDuration,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.surface.withValues(alpha: 0.95)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.accentHover.withValues(alpha: 0.7)
                : AppColors.cardBorder,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: AppColors.accent.withValues(alpha: 0.06),
            splashColor: AppColors.accent.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.booking.serviceName ?? 'Service',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(widget.booking.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _statusColor(widget.booking.status)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          widget.booking.status.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _statusColor(widget.booking.status),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    context,
                    Icons.calendar_today,
                    dateFormat.format(widget.booking.bookingDate),
                  ),
                  const SizedBox(height: 6),
                  _infoRow(
                    context,
                    Icons.access_time,
                    '${widget.booking.startTime} – ${widget.booking.endTime}',
                  ),
                  if (widget.booking.stylistName != null) ...[
                    const SizedBox(height: 6),
                    _infoRow(context, Icons.person, widget.booking.stylistName!),
                  ],
                  if (widget.booking.notesCustomer != null &&
                      widget.booking.notesCustomer!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.booking.notesCustomer!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  if (widget.booking.canCancel ||
                      widget.booking.canReschedule ||
                      widget.booking.isCompleted) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.booking.canReschedule)
                          TextButton.icon(
                            onPressed: widget.onReschedule,
                            icon: const Icon(Icons.edit_calendar, size: 18),
                            label: const Text('Reschedule'),
                          ),
                        if (widget.booking.canCancel)
                          TextButton.icon(
                            onPressed: widget.onCancel,
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        if (widget.booking.isCompleted)
                          TextButton.icon(
                            onPressed: widget.onReview,
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: const Text('Review'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            )),
      ],
    );
  }
}
