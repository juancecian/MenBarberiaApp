import 'package:flutter/foundation.dart';

enum NavigationItem {
  inicio,
  barberos,
  historial,
  configuracion,
}

class NavigationProvider with ChangeNotifier {
  NavigationItem _currentItem = NavigationItem.inicio;
  bool _isCollapsed = false;

  NavigationItem get currentItem => _currentItem;
  bool get isCollapsed => _isCollapsed;

  void setCurrentItem(NavigationItem item) {
    if (_currentItem != item) {
      _currentItem = item;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isCollapsed = !_isCollapsed;
    notifyListeners();
  }

  String get currentTitle {
    switch (_currentItem) {
      case NavigationItem.inicio:
        return 'Dashboard';
      case NavigationItem.barberos:
        return 'Gestión de Barberos';
      case NavigationItem.historial:
        return 'Historial de Servicios';
      case NavigationItem.configuracion:
        return 'Configuración';
    }
  }
}