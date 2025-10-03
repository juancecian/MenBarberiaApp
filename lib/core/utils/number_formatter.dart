import 'package:intl/intl.dart';

/// Utilidades para formatear números y precios
class NumberFormatter {
  /// Formateador para números con separadores de miles
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'es_ES');
  
  /// Formateador para precios con separadores de miles y decimales
  static final NumberFormat _priceFormat = NumberFormat('#,##0.00', 'es_ES');

  /// Formatea un número entero con separadores de miles
  /// Ejemplo: 10000 -> "10.000"
  static String formatNumber(int number) {
    return _numberFormat.format(number);
  }

  /// Formatea un precio (double) con separadores de miles
  /// Ejemplo: 10000.0 -> "10.000"
  /// Ejemplo: 10000.50 -> "10.000,50"
  static String formatPrice(double price) {
    // Si el precio es un número entero, no mostrar decimales
    if (price == price.truncateToDouble()) {
      return _numberFormat.format(price.toInt());
    }
    return _priceFormat.format(price);
  }

  /// Formatea el precio del servicio con la propina si existe
  /// Ejemplo: precio=5000, propina=0 -> "5.000"
  /// Ejemplo: precio=5000, propina=500 -> "5.000 - Propina: 500"
  static String formatServicePrice(double precio, double propina) {
    final precioFormateado = formatPrice(precio);
    
    if (propina > 0) {
      final propinaFormateada = formatPrice(propina);
      return '$precioFormateado - Propina: $propinaFormateada';
    }
    
    return precioFormateado;
  }

  /// Formatea el total del servicio (precio + propina)
  /// Ejemplo: 5500.0 -> "5.500"
  static String formatTotal(double total) {
    return formatPrice(total);
  }
}
