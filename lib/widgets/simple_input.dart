import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

/// Simple elegant input field with clean design
/// Minimalist approach without Material Design floating labels
class SimpleInput extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
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
  final FocusNode? focusNode;

  const SimpleInput({
    super.key,
    required this.controller,
    required this.placeholder,
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
    this.focusNode,
  });

  @override
  State<SimpleInput> createState() => _SimpleInputState();
}

class _SimpleInputState extends State<SimpleInput> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

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
    return SizedBox(
      height: 76, // Fixed height to accommodate error text
      child: Stack(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.secondaryColor.withOpacity(0.3),
                width: 1.0,
              ),
              color: _hasError
                ? AppTheme.errorColor.withOpacity(0.1)
                : (widget.enabled 
                  ? AppTheme.surfaceColor
                  : AppTheme.secondaryColor.withOpacity(0.1)),
            ),
            child: Focus(
              onFocusChange: _onFocusChange,
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
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
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: widget.icon != null ? 48 : 16,
                    right: widget.suffix != null ? 48 : 16,
                    top: 16,
                    bottom: 16,
                  ),
                  prefixIcon: widget.icon != null 
                    ? Icon(
                        widget.icon,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        size: 20,
                      )
                    : null,
                  suffixIcon: widget.suffix,
                ),
                validator: widget.validator,
              ),
            ),
          ),
          
          // Error Text - Positioned absolutely
          if (_hasError && _errorText != null)
            Positioned(
              top: 58,
              left: 12,
              right: 12,
              child: Text(
                _errorText!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Simple elegant dropdown with clean design
class SimpleDropdown<T> extends StatefulWidget {
  final T? value;
  final String placeholder;
  final IconData? icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const SimpleDropdown({
    super.key,
    required this.value,
    required this.placeholder,
    required this.items,
    required this.onChanged,
    this.icon,
    this.validator,
    this.enabled = true,
  });

  @override
  State<SimpleDropdown<T>> createState() => _SimpleDropdownState<T>();
}

class _SimpleDropdownState<T> extends State<SimpleDropdown<T>> {
  bool _hasError = false;
  String? _errorText;
  late FocusNode _focusNode;

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.value);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  /// Método público para validar desde el exterior (ej: al enviar formulario)
  bool validate() {
    _validateField();
    return !_hasError;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateField();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76, // Fixed height to accommodate error text
      child: Stack(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hasError 
                  ? AppTheme.errorColor 
                  : AppTheme.secondaryColor.withOpacity(0.3),
                width: 1.0,
              ),
              color: _hasError
                ? AppTheme.errorColor.withOpacity(0.1)
                : (widget.enabled 
                  ? AppTheme.surfaceColor
                  : AppTheme.secondaryColor.withOpacity(0.1)),
            ),
            child: DropdownButtonFormField<T>(
              focusNode: _focusNode,
              value: widget.value,
              items: widget.items,
              onChanged: (value) {
                // Llamar al callback original
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                // Limpiar error si se selecciona un valor
                if (value != null && _hasError) {
                  setState(() {
                    _hasError = false;
                    _errorText = null;
                  });
                }
              },
              validator: null, // Removemos el validator del FormField para usar solo el nuestro
              hint: Text(
                widget.placeholder,
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: widget.icon != null ? 48 : 16,
                  right: 40, // More space for dropdown arrow
                  top: 16,
                  bottom: 16,
                ),
                prefixIcon: widget.icon != null 
                  ? Icon(
                      widget.icon,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      size: 20,
                    )
                  : null,
              ),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              dropdownColor: AppTheme.surfaceColor,
              iconEnabledColor: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
          
          // Error Text - Positioned absolutely
          if (_hasError && _errorText != null)
            Positioned(
              top: 58,
              left: 12,
              right: 12,
              child: Text(
                _errorText!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
