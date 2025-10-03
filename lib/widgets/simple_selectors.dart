import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

/// Simple date selector with clean design
class SimpleDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final String placeholder;
  final IconData? icon;
  final void Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;

  const SimpleDateSelector({
    super.key,
    required this.selectedDate,
    required this.placeholder,
    required this.onDateSelected,
    this.icon,
    this.validator,
  });

  @override
  State<SimpleDateSelector> createState() => _SimpleDateSelectorState();
}

class _SimpleDateSelectorState extends State<SimpleDateSelector> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  Future<void> _selectDate() async {
    setState(() => _isFocused = true);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.black,
              surface: AppTheme.primaryColor,
              onSurface: AppTheme.textPrimary,
              background: AppTheme.backgroundColor,
              onBackground: AppTheme.textPrimary,
              secondary: AppTheme.secondaryColor,
              onSecondary: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.primaryColor,
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: TextStyle(color: AppTheme.textPrimary),
              bodyLarge: TextStyle(color: AppTheme.textPrimary),
              bodyMedium: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
          child: child!,
        );
      },
    );
    
    setState(() => _isFocused = false);
    
    if (picked != null) {
      widget.onDateSelected(picked);
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.selectedDate);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return SizedBox(
      height: 76, // Fixed height to accommodate error text
      child: Stack(
        children: [
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError 
                    ? AppTheme.errorColor
                    : (_isFocused 
                      ? AppTheme.accentColor
                      : AppTheme.secondaryColor.withOpacity(0.3)),
                  width: _hasError || _isFocused ? 2 : 1,
                ),
                color: AppTheme.primaryColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      dateFormat.format(widget.selectedDate),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
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

/// Simple time selector with clean design
class SimpleTimeSelector extends StatefulWidget {
  final String selectedTime;
  final String placeholder;
  final IconData? icon;
  final void Function(String) onTimeSelected;
  final String? Function(String?)? validator;

  const SimpleTimeSelector({
    super.key,
    required this.selectedTime,
    required this.placeholder,
    required this.onTimeSelected,
    this.icon,
    this.validator,
  });

  @override
  State<SimpleTimeSelector> createState() => _SimpleTimeSelectorState();
}

class _SimpleTimeSelectorState extends State<SimpleTimeSelector> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  Future<void> _selectTime() async {
    setState(() => _isFocused = true);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(widget.selectedTime.split(':')[0]),
        minute: int.parse(widget.selectedTime.split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.black,
              surface: AppTheme.primaryColor,
              onSurface: AppTheme.textPrimary,
              background: AppTheme.backgroundColor,
              onBackground: AppTheme.textPrimary,
              secondary: AppTheme.secondaryColor,
              onSecondary: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.primaryColor,
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: TextStyle(color: AppTheme.textPrimary),
              bodyLarge: TextStyle(color: AppTheme.textPrimary),
              bodyMedium: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
          child: child!,
        );
      },
    );
    
    setState(() => _isFocused = false);
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      widget.onTimeSelected(timeString);
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.selectedTime);
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
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError 
                    ? AppTheme.errorColor
                    : (_isFocused 
                      ? AppTheme.accentColor
                      : AppTheme.secondaryColor.withOpacity(0.3)),
                  width: _hasError || _isFocused ? 2 : 1,
                ),
                color: AppTheme.primaryColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.selectedTime,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
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
