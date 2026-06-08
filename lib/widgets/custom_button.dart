import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/colors.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  Color _backgroundColor() {
    if (_isDisabled) return AppColors.disabled.withValues(alpha: 0.6);

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        if (_pressed) return AppColors.accentPressed;
        if (_hovered) return AppColors.accentHover;
        return AppColors.accent;
      case ButtonVariant.outline:
        if (_pressed) return AppColors.accent.withValues(alpha: 0.2);
        if (_hovered) return AppColors.accent.withValues(alpha: 0.12);
        return Colors.transparent;
      case ButtonVariant.danger:
        if (_pressed) return AppColors.error.withValues(alpha: 0.85);
        if (_hovered) return AppColors.error.withValues(alpha: 0.9);
        return AppColors.error;
    }
  }

  Color _foregroundColor() {
    if (_isDisabled) return AppColors.textSecondary;

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.outline:
        if (_hovered || _pressed) return AppColors.accentHover;
        return AppColors.primary;
      case ButtonVariant.danger:
        return AppColors.textPrimary;
    }
  }

  Border? _border() {
    if (widget.variant != ButtonVariant.outline) return null;

    final borderColor = _isDisabled
        ? AppColors.disabled.withValues(alpha: 0.6)
        : (_hovered || _pressed ? AppColors.accentHover : AppColors.primary);

    return Border.all(color: borderColor, width: 1.5);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _foregroundColor(),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: _foregroundColor()),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _foregroundColor(),
                    ),
              ),
            ],
          );

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: MouseRegion(
        onEnter: _isDisabled ? null : (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTapDown: _isDisabled ? null : (_) => setState(() => _pressed = true),
          onTapUp: _isDisabled ? null : (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _isDisabled ? null : widget.onPressed,
          child: AnimatedScale(
            scale: _pressed && !_isDisabled ? 0.98 : 1.0,
            duration: AppTheme.hoverDuration,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: AppTheme.hoverDuration,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _backgroundColor(),
                border: _border(),
                borderRadius: BorderRadius.circular(14),
                boxShadow: widget.variant == ButtonVariant.primary &&
                        !_isDisabled &&
                        _hovered
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
