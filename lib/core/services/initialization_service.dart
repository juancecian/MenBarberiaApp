import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'window_service.dart';
import 'supabase_service.dart';
import 'sync_service.dart';
import '../database/database_service.dart';

/// Represents an initialization step with progress tracking
class InitializationStep {
  final String id;
  final String title;
  final String description;
  final Future<void> Function() action;
  final double weight; // Relative weight for progress calculation

  const InitializationStep({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    this.weight = 1.0,
  });
}

/// Initialization state for tracking progress
class InitializationState {
  final String currentStep;
  final String currentDescription;
  final double progress;
  final bool isCompleted;
  final String? error;

  const InitializationState({
    required this.currentStep,
    required this.currentDescription,
    required this.progress,
    required this.isCompleted,
    this.error,
  });

  InitializationState copyWith({
    String? currentStep,
    String? currentDescription,
    double? progress,
    bool? isCompleted,
    String? error,
  }) {
    return InitializationState(
      currentStep: currentStep ?? this.currentStep,
      currentDescription: currentDescription ?? this.currentDescription,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

/// Senior-level initialization service with progress tracking
/// Implements Observer pattern for real-time updates
class InitializationService {
  static final InitializationService _instance = InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  // Stream controller for broadcasting initialization state
  final List<Function(InitializationState)> _listeners = [];
  
  InitializationState _currentState = const InitializationState(
    currentStep: 'Preparando...',
    currentDescription: 'Iniciando servicios de la aplicación',
    progress: 0.0,
    isCompleted: false,
  );

  /// Add listener for initialization state changes
  void addListener(Function(InitializationState) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(InitializationState) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of state change
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_currentState);
      } catch (e) {
        debugPrint('InitializationService: Listener error - $e');
      }
    }
  }

  /// Update current state and notify listeners
  void _updateState(InitializationState newState) {
    _currentState = newState;
    _notifyListeners();
  }

  /// Get current initialization state
  InitializationState get currentState => _currentState;

  /// Define all initialization steps with proper sequencing
  List<InitializationStep> get _initializationSteps => [
    InitializationStep(
      id: 'window_service',
      title: 'Configurando Ventana',
      description: 'Optimizando tamaño y posición de ventana...',
      weight: 1.5,
      action: () async {
        await WindowService().initialize();
        await Future.delayed(const Duration(milliseconds: 500)); // Visual feedback
      },
    ),
    InitializationStep(
      id: 'sqlite_setup',
      title: 'Configurando Base de Datos',
      description: 'Inicializando SQLite para escritorio...',
      weight: 1.0,
      action: () async {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      },
    ),
    InitializationStep(
      id: 'supabase_init',
      title: 'Conectando con el servidor',
      description: 'Inicializando servicios en la nube...',
      weight: 1.5,
      action: () async {
        try {
          await SupabaseService().initialize();
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error al conectar con Supabase: $e');
          }
          // Continuar sin conexión si hay un error
        }
      },
    ),
    InitializationStep(
      id: 'database_init',
      title: 'Preparando Datos',
      description: 'Creando tablas y verificando integridad...',
      weight: 2.0,
      action: () async {
        await DatabaseService().initDatabase();
        await Future.delayed(const Duration(milliseconds: 400));
      },
    ),
    InitializationStep(
      id: 'sync_init',
      title: 'Sincronizando Datos',
      description: 'Actualizando información desde la nube...',
      weight: 2.5,
      action: () async {
        try {
          final syncService = SyncService();
          await syncService.initialize();
          
          // Actualizar descripción para mostrar progreso específico
          _updateState(_currentState.copyWith(
            currentDescription: 'Descargando barberos desde Supabase...',
          ));
          
          // Intentar sincronización completa inicial
          final result = await syncService.syncAll();
          if (result.success) {
            if (kDebugMode) {
              print('✅ Sincronización inicial exitosa: ${result.message}');
            }
            
            // Actualizar descripción para mostrar éxito
            _updateState(_currentState.copyWith(
              currentDescription: 'Datos sincronizados correctamente',
            ));
          } else {
            if (kDebugMode) {
              print('⚠️ Sincronización inicial falló: ${result.message}');
            }
            
            // Actualizar descripción para mostrar modo offline
            _updateState(_currentState.copyWith(
              currentDescription: 'Continuando en modo offline...',
            ));
          }
          
          await Future.delayed(const Duration(milliseconds: 800));
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error en sincronización inicial: $e');
          }
          
          // Actualizar descripción para mostrar error pero continuación
          _updateState(_currentState.copyWith(
            currentDescription: 'Sin conexión - modo offline activado',
          ));
          
          await Future.delayed(const Duration(milliseconds: 500));
        }
      },
    ),
    InitializationStep(
      id: 'app_ready',
      title: 'Finalizando',
      description: 'Preparando interfaz de usuario...',
      weight: 0.5,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
    ),
  ];

  /// Execute all initialization steps with progress tracking
  Future<bool> initialize() async {
    try {
      final steps = _initializationSteps;
      final totalWeight = steps.fold<double>(0.0, (sum, step) => sum + step.weight);
      double currentProgress = 0.0;

      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        
        // Update state to show current step
        _updateState(_currentState.copyWith(
          currentStep: step.title,
          currentDescription: step.description,
          progress: currentProgress / totalWeight,
        ));

        debugPrint('InitializationService: Executing ${step.id}...');
        
        try {
          // Execute the step
          await step.action();
          
          // Update progress
          currentProgress += step.weight;
          
          // Update state with new progress
          _updateState(_currentState.copyWith(
            progress: currentProgress / totalWeight,
          ));
          
          debugPrint('InitializationService: ${step.id} completed successfully');
          
        } catch (e, stackTrace) {
          debugPrint('InitializationService: Error in ${step.id} - $e');
          debugPrint('StackTrace: $stackTrace');
          
          // Update state with error
          _updateState(_currentState.copyWith(
            error: 'Error en ${step.title}: $e',
          ));
          
          // For critical errors, stop initialization
          if (step.id == 'database_init') {
            return false;
          }
          
          // For non-critical errors, continue with degraded functionality
          continue;
        }
      }

      // Mark as completed
      _updateState(_currentState.copyWith(
        currentStep: 'Completado',
        currentDescription: 'Men Barbería está listo para usar',
        progress: 1.0,
        isCompleted: true,
      ));

      debugPrint('InitializationService: All services initialized successfully');
      return true;

    } catch (e, stackTrace) {
      debugPrint('InitializationService: Fatal initialization error - $e');
      debugPrint('StackTrace: $stackTrace');
      
      _updateState(_currentState.copyWith(
        error: 'Error crítico durante la inicialización: $e',
      ));
      
      return false;
    }
  }

  /// Reset initialization state (useful for testing or restart)
  void reset() {
    _currentState = const InitializationState(
      currentStep: 'Preparando...',
      currentDescription: 'Iniciando servicios de la aplicación',
      progress: 0.0,
      isCompleted: false,
    );
    _notifyListeners();
  }

  /// Get initialization summary for debugging
  Map<String, dynamic> getInitializationSummary() {
    return {
      'currentStep': _currentState.currentStep,
      'progress': _currentState.progress,
      'isCompleted': _currentState.isCompleted,
      'hasError': _currentState.error != null,
      'error': _currentState.error,
      'totalSteps': _initializationSteps.length,
    };
  }
}
