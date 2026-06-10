import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/colors.dart';

/// A card that shows a gold border-glow + shadow on desktop hover and an
/// InkWell ripple on mobile tap (when [onTap] is provided).
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppTheme.hoverDuration,
        curve: Curves.easeOut,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: widget.borderRadius,
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
        child: widget.onTap != null
            ? Material(
                color: Colors.transparent,
                borderRadius: widget.borderRadius,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: widget.borderRadius,
                  hoverColor: Colors.transparent,
                  splashColor: AppColors.accent.withValues(alpha: 0.1),
                  highlightColor: AppColors.accent.withValues(alpha: 0.05),
                  child: widget.child,
                ),
              )
            : widget.child,
      ),
    );
  }
}
