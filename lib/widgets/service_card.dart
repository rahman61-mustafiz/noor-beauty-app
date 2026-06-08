import 'package:flutter/material.dart';

import '../models/service.dart';
import '../utils/app_theme.dart';
import '../utils/colors.dart';

class ServiceCard extends StatefulWidget {
  final SalonService service;
  final VoidCallback? onTap;
  final bool isSelected;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovered = false;

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
      child: GestureDetector(
        onTap: widget.onTap,
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
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppTheme.hoverDuration,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _hovered || widget.isSelected
                        ? AppColors.accentGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.service.iconData,
                    color: AppColors.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.service.baseDurationMin}–${widget.service.baseDurationMax} min',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: _hovered ? AppColors.accentHover : AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
