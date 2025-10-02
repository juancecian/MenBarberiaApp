import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

/// Elegant date selector with professional styling
class ElegantDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final String label;
  final IconData? icon;
  final void Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;

  const ElegantDateSelector({
    super.key,
    required this.selectedDate,
    required this.label,
    required this.onDateSelected,
    this.icon,
    this.validator,
  });

  @override
  State<ElegantDateSelector> createState() => _ElegantDateSelectorState();
}

class _ElegantDateSelectorState extends State<ElegantDateSelector>
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
    _animationController.forward(); // Always show label as floating
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.accentColor,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surfaceColor,
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasError 
                  ? AppTheme.errorColor
                  : (_isFocused ? AppTheme.accentColor : AppTheme.secondaryColor),
                width: _isFocused ? 2.0 : 1.0,
              ),
              color: AppTheme.primaryColor.withOpacity(0.5),
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
                // Date Display
                Positioned(
                  left: widget.icon != null ? 48 : 16,
                  top: 24,
                  child: Text(
                    dateFormat.format(widget.selectedDate),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Label
                Positioned(
                  left: widget.icon != null ? 48 : 16,
                  top: 8,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _hasError 
                        ? AppTheme.errorColor
                        : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                
                // Calendar Icon
                const Positioned(
                  right: 16,
                  top: 16,
                  child: Icon(
                    Icons.calendar_today,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
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

/// Elegant time selector with professional styling
class ElegantTimeSelector extends StatefulWidget {
  final String selectedTime;
  final String label;
  final IconData? icon;
  final void Function(String) onTimeSelected;
  final String? Function(String?)? validator;

  const ElegantTimeSelector({
    super.key,
    required this.selectedTime,
    required this.label,
    required this.onTimeSelected,
    this.icon,
    this.validator,
  });

  @override
  State<ElegantTimeSelector> createState() => _ElegantTimeSelectorState();
}

class _ElegantTimeSelectorState extends State<ElegantTimeSelector>
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
    _animationController.forward(); // Always show label as floating
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.accentColor,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surfaceColor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasError 
                  ? AppTheme.errorColor
                  : (_isFocused ? AppTheme.accentColor : AppTheme.secondaryColor),
                width: _isFocused ? 2.0 : 1.0,
              ),
              color: AppTheme.primaryColor.withOpacity(0.5),
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
                // Time Display
                Positioned(
                  left: widget.icon != null ? 48 : 16,
                  top: 24,
                  child: Text(
                    widget.selectedTime,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Label
                Positioned(
                  left: widget.icon != null ? 48 : 16,
                  top: 8,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _hasError 
                        ? AppTheme.errorColor
                        : (_isFocused ? AppTheme.accentColor : AppTheme.textSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                
                // Clock Icon
                const Positioned(
                  right: 16,
                  top: 16,
                  child: Icon(
                    Icons.access_time,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
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
