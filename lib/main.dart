import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'services/update_service.dart';
import 'providers/barbero_provider.dart';
import 'providers/servicio_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/splash_screen.dart';
import 'package:auto_updater/auto_updater.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  final supabaseService = SupabaseService();
  
  // Verificar conexión
  final isConnected = await supabaseService.initialize();
  
  // Mostrar el estado de la conexión en consola
  if (isConnected) {
    print('✅ Aplicación conectada a Supabase');
  } else {
    print('❌ No se pudo conectar a Supabase');
  }

  // Lanzar la aplicación
  runApp(MenBarberiaApp(supabaseService: supabaseService));
}

class MenBarberiaApp extends StatelessWidget {
  final SupabaseService supabaseService;
  
  const MenBarberiaApp({
    super.key, 
    required this.supabaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(create: (_) => BarberoProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp(
        title: 'Men Barbería',
        home: const SplashScreen(),
      ),
    );
  }
}