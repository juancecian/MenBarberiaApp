import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Widget que integra el sistema de actualizaciones real de desktop_updater
/// Solo funciona en builds de release
class DesktopUpdaterWidget extends StatefulWidget {
  final Widget child;
  
  const DesktopUpdaterWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<DesktopUpdaterWidget> createState() => _DesktopUpdaterWidgetState();
}

class _DesktopUpdaterWidgetState extends State<DesktopUpdaterWidget> {
  @override
  Widget build(BuildContext context) {
    // En modo debug o plataformas no desktop, solo mostrar el child
    if (kDebugMode || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return widget.child;
    }

    // En release, aquí se integraría el widget real de desktop_updater
    // Por ahora, solo devolver el child hasta que se configure correctamente
    return widget.child;
  }
}

/// Widget para mostrar actualizaciones como diálogo
class DesktopUpdaterDialogListener extends StatefulWidget {
  const DesktopUpdaterDialogListener({Key? key}) : super(key: key);

  @override
  State<DesktopUpdaterDialogListener> createState() => _DesktopUpdaterDialogListenerState();
}

class _DesktopUpdaterDialogListenerState extends State<DesktopUpdaterDialogListener> {
  @override
  Widget build(BuildContext context) {
    // En modo debug o plataformas no desktop, no mostrar nada
    if (kDebugMode || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return const SizedBox.shrink();
    }

    // En release, aquí se integraría el listener de desktop_updater
    return const SizedBox.shrink();
  }
}

/// Widget de tarjeta de actualización directa
class DesktopUpdaterCard extends StatefulWidget {
  final Widget? child;
  
  const DesktopUpdaterCard({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  State<DesktopUpdaterCard> createState() => _DesktopUpdaterCardState();
}

class _DesktopUpdaterCardState extends State<DesktopUpdaterCard> {
  @override
  Widget build(BuildContext context) {
    // En modo debug o plataformas no desktop, mostrar solo el child
    if (kDebugMode || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return widget.child ?? const SizedBox.shrink();
    }

    // En release, aquí se integraría la tarjeta directa de desktop_updater
    return widget.child ?? const SizedBox.shrink();
  }
}
