import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// Abstract interface for window management operations
/// Following Interface Segregation Principle
abstract class IWindowService {
  Future<void> initialize();
  Future<void> setMinimumSize(Size size);
  Future<void> setInitialSize(Size size);
  Future<void> centerWindow();
  Future<Size> getScreenSize();
  Future<void> configureDesktopWindow();
}

/// Concrete implementation of window service
/// Handles desktop window configuration with senior-level practices
class WindowService implements IWindowService {
  static const double _screenPercentage = 0.8;
  static const Size _fallbackMinSize = Size(1200, 800);
  
  /// Singleton pattern for service consistency
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Only initialize on desktop platforms
      if (!_isDesktopPlatform()) {
        _isInitialized = true;
        return;
      }

      await windowManager.ensureInitialized();
      await configureDesktopWindow();
      _isInitialized = true;
      
      debugPrint('WindowService: Successfully initialized for ${Platform.operatingSystem}');
    } catch (e, stackTrace) {
      debugPrint('WindowService: Initialization failed - $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> configureDesktopWindow() async {
    if (!_isDesktopPlatform()) return;

    try {
      final screenSize = await getScreenSize();
      final windowSize = _calculateWindowSize(screenSize);
      
      // Configure window options with comprehensive settings
      const windowOptions = WindowOptions(
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await setInitialSize(windowSize);
        await setMinimumSize(windowSize);
        await centerWindow();
        await windowManager.show();
        await windowManager.focus();
      });

      debugPrint('WindowService: Window configured - Size: ${windowSize.width}x${windowSize.height}');
    } catch (e) {
      debugPrint('WindowService: Configuration failed - $e');
      await _fallbackConfiguration();
    }
  }

  @override
  Future<Size> getScreenSize() async {
    try {
      final primaryDisplay = await screenRetriever.getPrimaryDisplay();
      return Size(
        primaryDisplay.size.width,
        primaryDisplay.size.height,
      );
    } catch (e) {
      debugPrint('WindowService: Failed to get screen size, using fallback - $e');
      return const Size(1920, 1080); // Common fallback resolution
    }
  }

  @override
  Future<void> setInitialSize(Size size) async {
    if (!_isDesktopPlatform()) return;
    
    try {
      await windowManager.setSize(size);
    } catch (e) {
      debugPrint('WindowService: Failed to set initial size - $e');
    }
  }

  @override
  Future<void> setMinimumSize(Size size) async {
    if (!_isDesktopPlatform()) return;
    
    try {
      await windowManager.setMinimumSize(size);
    } catch (e) {
      debugPrint('WindowService: Failed to set minimum size - $e');
    }
  }

  @override
  Future<void> centerWindow() async {
    if (!_isDesktopPlatform()) return;
    
    try {
      await windowManager.center();
    } catch (e) {
      debugPrint('WindowService: Failed to center window - $e');
    }
  }

  /// Calculate optimal window size based on screen dimensions
  /// Applies 80% rule with intelligent constraints
  Size _calculateWindowSize(Size screenSize) {
    final calculatedWidth = screenSize.width * _screenPercentage;
    final calculatedHeight = screenSize.height * _screenPercentage;
    
    // Ensure minimum viable size for barbershop application
    final width = calculatedWidth.clamp(_fallbackMinSize.width, screenSize.width);
    final height = calculatedHeight.clamp(_fallbackMinSize.height, screenSize.height);
    
    return Size(width, height);
  }

  /// Fallback configuration for error scenarios
  Future<void> _fallbackConfiguration() async {
    try {
      await setInitialSize(_fallbackMinSize);
      await setMinimumSize(_fallbackMinSize);
      await centerWindow();
      debugPrint('WindowService: Fallback configuration applied');
    } catch (e) {
      debugPrint('WindowService: Fallback configuration also failed - $e');
    }
  }

  /// Platform detection utility
  bool _isDesktopPlatform() {
    return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  /// Get current window state for debugging/monitoring
  Future<Map<String, dynamic>> getWindowInfo() async {
    if (!_isDesktopPlatform()) {
      return {'platform': 'non-desktop', 'supported': false};
    }

    try {
      final size = await windowManager.getSize();
      final position = await windowManager.getPosition();
      final isVisible = await windowManager.isVisible();
      final isFocused = await windowManager.isFocused();
      
      return {
        'platform': Platform.operatingSystem,
        'supported': true,
        'size': {'width': size.width, 'height': size.height},
        'position': {'x': position.dx, 'y': position.dy},
        'isVisible': isVisible,
        'isFocused': isFocused,
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      return {
        'platform': Platform.operatingSystem,
        'supported': true,
        'error': e.toString(),
        'isInitialized': _isInitialized,
      };
    }
  }
}

/// Extension for easy access to window service
extension WindowServiceExtension on BuildContext {
  WindowService get windowService => WindowService();
}
