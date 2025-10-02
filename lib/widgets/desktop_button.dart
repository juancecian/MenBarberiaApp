import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Professional desktop button with hover effects
/// Optimized for desktop applications with senior-level UX
class DesktopButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  const DesktopButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  @override
  State<DesktopButton> createState() => _DesktopButtonState();
}

class _DesktopButtonState extends State<DesktopButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted && widget.onPressed != null) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.isPrimary ? _buildPrimaryButton() : _buildSecondaryButton(),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: widget.icon,
      label: Text(widget.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? AppTheme.accentColor,
        foregroundColor: widget.foregroundColor ?? Colors.black,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: _elevationAnimation.value,
        shadowColor: (widget.backgroundColor ?? AppTheme.accentColor).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton.icon(
      onPressed: widget.onPressed,
      icon: widget.icon,
      label: Text(widget.label),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.foregroundColor ?? AppTheme.accentColor,
        side: BorderSide(
          color: widget.backgroundColor ?? AppTheme.accentColor,
          width: _isHovered ? 2.0 : 1.0,
        ),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: _isHovered 
          ? (widget.backgroundColor ?? AppTheme.accentColor).withOpacity(0.1)
          : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
