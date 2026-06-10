import 'package:flutter/material.dart';

import '../models/service.dart';
import '../utils/app_theme.dart';
import '../utils/colors.dart';

class ServiceCard extends StatefulWidget {
  final SalonService service;
  final VoidCallback? onTap;
  final bool isSelected;
  final void Function(ServiceSubOption)? onSubOptionBook;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.isSelected = false,
    this.onSubOptionBook,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovered = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected
        ? AppColors.primary
        : _hovered
            ? AppColors.accentHover.withValues(alpha: 0.7)
            : AppColors.cardBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppTheme.hoverDuration,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : _hovered
                  ? AppColors.surface.withValues(alpha: 0.95)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: widget.isSelected ? 2 : 1),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // ── Main row ────────────────────────────────────────────────
              InkWell(
                onTap: widget.onSubOptionBook != null
                    ? () => setState(() => _expanded = !_expanded)
                    : widget.onTap,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: _expanded ? Radius.zero : const Radius.circular(16),
                ),
                hoverColor: Colors.transparent,
                splashColor: AppColors.accent.withValues(alpha: 0.1),
                highlightColor: AppColors.accent.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon box
                      AnimatedContainer(
                        duration: AppTheme.hoverDuration,
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          gradient: _hovered || widget.isSelected
                              ? AppColors.accentGradient
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(widget.service.iconData, color: AppColors.secondary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.service.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${widget.service.baseDurationMin}–${widget.service.baseDurationMax} min',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: _hovered ? AppColors.accentHover : AppColors.primary,
                                      ),
                                ),
                                if (widget.service.startingPrice > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'From ৳${widget.service.startingPrice}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: _hovered ? AppColors.accentHover : AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Expand arrow or selected check
                      if (widget.isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary)
                      else if (widget.onSubOptionBook != null)
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: AppTheme.hoverDuration,
                          child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Sub-options ──────────────────────────────────────────────
              if (_expanded && widget.service.subOptions.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.cardBorder)),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Column(
                    children: widget.service.subOptions.map((opt) {
                      return _SubOptionRow(
                        option: opt,
                        onBook: () => widget.onSubOptionBook?.call(opt),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubOptionRow extends StatelessWidget {
  final ServiceSubOption option;
  final VoidCallback onBook;

  const _SubOptionRow({required this.option, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${option.durationMin} min', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '৳${option.price}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
