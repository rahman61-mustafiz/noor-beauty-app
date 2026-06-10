import 'package:flutter/material.dart';

import '../models/stylist.dart';
import '../utils/app_theme.dart';
import '../utils/colors.dart';

class StylistCard extends StatefulWidget {
  final Stylist stylist;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const StylistCard({
    super.key,
    required this.stylist,
    this.onTap,
    this.isSelected = false,
    this.showFavorite = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<StylistCard> createState() => _StylistCardState();
}

class _StylistCardState extends State<StylistCard> {
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
      child: AnimatedContainer(
        duration: AppTheme.hoverDuration,
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: Colors.transparent,
            splashColor: AppColors.accent.withValues(alpha: 0.1),
            highlightColor: AppColors.accent.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          widget.stylist.name.isNotEmpty
                              ? widget.stylist.name[0].toUpperCase()
                              : '?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: _hovered ? AppColors.accentHover : AppColors.primary,
                              ),
                        ),
                      ),
                      if (widget.showFavorite)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.onFavoriteToggle,
                              child: AnimatedSwitcher(
                                duration: AppTheme.hoverDuration,
                                child: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey(widget.isFavorite),
                                  color: widget.isFavorite
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.stylist.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: _hovered ? AppColors.accentHover : AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.stylist.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: widget.stylist.specialties.take(2).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.cardBorder.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          s,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
