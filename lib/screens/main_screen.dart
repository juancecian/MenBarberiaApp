import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/barbero_provider.dart';
import '../providers/servicio_provider.dart';
import '../widgets/sidebar.dart';
import 'dashboard_screen.dart';
import 'barberos_screen.dart';
import 'historial_screen.dart';
import 'configuracion_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isInitialized && mounted) {
        try {
          _isInitialized = true;
          final barberoProvider = context.read<BarberoProvider>();
          final servicioProvider = context.read<ServicioProvider>();
          
          // Cargar datos en paralelo
          await Future.wait([
            barberoProvider.loadBarberos(),
            servicioProvider.loadServicios(
              fecha: DateTime.now().toIso8601String().split('T')[0],
            ),
          ]);
        } catch (e) {
          if (mounted) {
            // Mostrar mensaje de error al usuario si es necesario
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
            );
          }
        }
      }
    });
  }

  Widget _getCurrentScreen(NavigationItem currentItem) {
    switch (currentItem) {
      case NavigationItem.inicio:
        return const DashboardScreen();
      case NavigationItem.barberos:
        return const BarberosScreen();
      case NavigationItem.historial:
        return const HistorialScreen();
      case NavigationItem.configuracion:
        return const ConfiguracionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return Row(
            children: [
              // Sidebar
              CustomSidebar(),
              
              // Main Content
              Expanded(
                child: Container(
                  child: _getCurrentScreen(navigationProvider.currentItem),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}