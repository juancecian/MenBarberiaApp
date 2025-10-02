import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../core/services/initialization_service.dart';
import '../core/theme/app_theme.dart';
import 'main_screen.dart';

/// Professional splash screen with elegant animations and progress tracking
/// Implements senior-level UX patterns for desktop applications
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressOpacity;
  late Animation<double> _pulseAnimation;
  
  InitializationState _initState = const InitializationState(
    currentStep: 'Preparando...',
    currentDescription: 'Iniciando servicios de la aplicación',
    progress: 0.0,
    isCompleted: false,
  );

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Progress animations
    _progressOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for loading indicator
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.forward();
    
    // Delay progress animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _progressController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _startInitialization() {
    final initService = InitializationService();
    
    // Listen to initialization progress
    initService.addListener(_onInitializationUpdate);
    
    // Start initialization process
    initService.initialize().then((success) {
      if (mounted && success) {
        _navigateToMainScreen();
      } else if (mounted) {
        _showErrorDialog();
      }
    });
  }

  void _onInitializationUpdate(InitializationState state) {
    if (mounted) {
      setState(() {
        _initState = state;
      });
    }
  }

  void _navigateToMainScreen() {
    if (_isNavigating) return;
    _isNavigating = true;

    // Add a small delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de Inicialización'),
        content: Text(
          _initState.error ?? 'Error desconocido durante la inicialización',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Reintentar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToMainScreen(); // Continue with degraded functionality
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _initState = const InitializationState(
        currentStep: 'Preparando...',
        currentDescription: 'Reiniciando servicios...',
        progress: 0.0,
        isCompleted: false,
      );
    });
    
    InitializationService().reset();
    _startInitialization();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _buildLogo(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Progress Section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _progressOpacity,
                    child: _buildProgressSection(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // App Icon/Logo
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _initState.isCompleted ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut,
                  size: 60,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // App Name
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: Text(
            'Men Barbería',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        FadeInUp(
          delay: const Duration(milliseconds: 700),
          child: Text(
            'Sistema de Gestión Profesional',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          // Current Step Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              _initState.currentStep,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Current Step Description
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              _initState.currentDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Progress Bar
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildProgressBar(),
          ),
          
          const SizedBox(height: 16),
          
          // Progress Percentage
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              '${(_initState.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 300 * _initState.progress,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor,
                AppTheme.accentColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
