import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

/// Elegant input field with professional styling
/// Designed for desktop applications with sophisticated UX
class ElegantInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffix;

  const ElegantInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.suffix,
  });

  @override
  State<ElegantInput> createState() => _ElegantInputState();
}

class _ElegantInputState extends State<ElegantInput>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _iconScaleAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: AppTheme.secondaryColor,
      end: AppTheme.accentColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText && !_isFocused) {
      _animationController.forward();
    } else if (!hasText && !_isFocused) {
      _animationController.reverse();
    }
    
    // Validate on text change
    if (_hasError) {
      _validateField();
    }
  }

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus || widget.controller.text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    if (!hasFocus) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasError 
                ? AppTheme.errorColor
                : (_isFocused ? AppTheme.accentColor : AppTheme.secondaryColor),
              width: _isFocused ? 2.0 : 1.0,
            ),
            color: widget.enabled 
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.secondaryColor.withOpacity(0.3),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AppTheme.accentColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Stack(
            children: [
              // Input Field
              Positioned.fill(
                child: Focus(
                  onFocusChange: _onFocusChange,
                  child: TextFormField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    obscureText: widget.obscureText,
                    maxLines: widget.maxLines,
                    enabled: widget.enabled,
                    onTap: widget.onTap,
                    readOnly: widget.readOnly,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: widget.icon != null ? 48 : 16,
                        right: widget.suffix != null ? 48 : 16,
                        top: 16,
                        bottom: 16,
                      ),
                      hintText: _isFocused ? widget.hint : null,
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    validator: widget.validator,
                  ),
                ),
              ),
              
              // Animated Label
              AnimatedBuilder(
                animation: _labelAnimation,
                builder: (context, child) {
                  final isFloating = _isFocused || widget.controller.text.isNotEmpty;
                  return Positioned(
                    left: widget.icon != null ? 48 : 16,
                    top: isFloating ? 8 : 16,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _hasError 
                          ? AppTheme.errorColor
                          : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                        fontSize: isFloating ? 12 : 16,
                        fontWeight: isFloating ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(widget.label),
                    ),
                  );
                },
              ),
              
              // Icon
              if (widget.icon != null)
                Positioned(
                  left: 16,
                  top: 16,
                  child: AnimatedBuilder(
                    animation: _iconScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isFocused ? _iconScaleAnimation.value : 1.0,
                        child: Icon(
                          widget.icon,
                          color: _hasError 
                            ? AppTheme.errorColor
                            : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              
              // Suffix
              if (widget.suffix != null)
                Positioned(
                  right: 16,
                  top: 16,
                  child: widget.suffix!,
                ),
            ],
          ),
        ),
        
        // Error Text
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Elegant dropdown with professional styling
class ElegantDropdown<T> extends StatefulWidget {
  final T? value;
  final String label;
  final IconData? icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const ElegantDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.icon,
    this.validator,
    this.enabled = true,
  });

  @override
  State<ElegantDropdown<T>> createState() => _ElegantDropdownState<T>();
}

class _ElegantDropdownState<T> extends State<ElegantDropdown<T>>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    if (widget.value != null) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.value);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasError 
                ? AppTheme.errorColor
                : (_isFocused ? AppTheme.accentColor : AppTheme.secondaryColor),
              width: _isFocused ? 2.0 : 1.0,
            ),
            color: widget.enabled 
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.secondaryColor.withOpacity(0.3),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AppTheme.accentColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Stack(
            children: [
              // Dropdown
              Positioned.fill(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _isFocused = hasFocus);
                    if (!hasFocus) _validateField();
                  },
                  child: DropdownButtonFormField<T>(
                    value: widget.value,
                    items: widget.items,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                      if (value != null) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    },
                    validator: widget.validator,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: widget.icon != null ? 48 : 16,
                        right: 16,
                        top: 16,
                        bottom: 16,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: AppTheme.surfaceColor,
                    iconEnabledColor: AppTheme.accentColor,
                  ),
                ),
              ),
              
              // Animated Label
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final isFloating = _isFocused || widget.value != null;
                  return Positioned(
                    left: widget.icon != null ? 48 : 16,
                    top: isFloating ? 8 : 16,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _hasError 
                          ? AppTheme.errorColor
                          : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                        fontSize: isFloating ? 12 : 16,
                        fontWeight: isFloating ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(widget.label),
                    ),
                  );
                },
              ),
              
              // Icon
              if (widget.icon != null)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Icon(
                    widget.icon,
                    color: _hasError 
                      ? AppTheme.errorColor
                      : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        
        // Error Text
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
