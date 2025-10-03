import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formateador de entrada para campos de precio que formatea automáticamente
/// los números con separadores de miles mientras el usuario escribe
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0', 'es_ES');
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si el texto está vacío, no hacer nada
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remover todos los caracteres que no sean dígitos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si no hay dígitos, retornar vacío
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Convertir a número y formatear
    int number = int.parse(digitsOnly);
    String formatted = _formatter.format(number);

    // Calcular la nueva posición del cursor
    int newCursorPosition = formatted.length;
    
    // Si el usuario está editando en el medio del texto, 
    // intentar mantener una posición relativa del cursor
    if (oldValue.text.isNotEmpty && newValue.selection.baseOffset < newValue.text.length) {
      // Contar cuántos dígitos hay antes de la posición del cursor
      String textBeforeCursor = newValue.text.substring(0, newValue.selection.baseOffset);
      int digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^\d]'), '').length;
      
      // Encontrar la posición correspondiente en el texto formateado
      int currentDigitCount = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'\d').hasMatch(formatted[i])) {
          currentDigitCount++;
          if (currentDigitCount == digitsBeforeCursor) {
            newCursorPosition = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  /// Método estático para obtener el valor numérico de un texto formateado
  static double getNumericValue(String formattedText) {
    if (formattedText.isEmpty) return 0.0;
    
    // Remover todos los caracteres que no sean dígitos
    String digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) return 0.0;
    
    return double.parse(digitsOnly);
  }
}
