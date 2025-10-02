import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/sync_provider.dart';
import '../core/theme/app_theme.dart';

/// Widget que muestra el estado de sincronización
class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;
  
  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(syncProvider).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(syncProvider).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(syncProvider),
              const SizedBox(width: 8),
              if (showDetails) ...[
                _buildStatusText(context, syncProvider),
              ] else ...[
                _buildSimpleStatus(context, syncProvider),
              ],
              if (!syncProvider.isSyncing) ...[
                const SizedBox(width: 8),
                _buildSyncButton(context, syncProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncProvider syncProvider) {
    if (syncProvider.isSyncing) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(_getStatusColor(syncProvider)),
        ),
      );
    }

    IconData icon;
    if (!syncProvider.isOnline) {
      icon = Icons.cloud_off;
    } else if (syncProvider.syncError != null) {
      icon = Icons.sync_problem;
    } else {
      icon = Icons.cloud_done;
    }

    return Icon(
      icon,
      size: 16,
      color: _getStatusColor(syncProvider),
    );
  }

  Widget _buildSimpleStatus(BuildContext context, SyncProvider syncProvider) {
    String status;
    if (syncProvider.isSyncing) {
      status = 'Sincronizando...';
    } else if (!syncProvider.isOnline) {
      status = 'Sin conexión';
    } else if (syncProvider.syncError != null) {
      status = 'Error de sync';
    } else {
      status = 'Sincronizado';
    }

    return Text(
      status,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: _getStatusColor(syncProvider),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, SyncProvider syncProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSimpleStatus(context, syncProvider),
        if (syncProvider.lastSyncTime != null && !syncProvider.isSyncing) ...[
          const SizedBox(height: 2),
          Text(
            'Última sync: ${_formatSyncTime(syncProvider.lastSyncTime!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSyncButton(BuildContext context, SyncProvider syncProvider) {
    return InkWell(
      onTap: () => _showSyncOptions(context, syncProvider),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.refresh,
          size: 14,
          color: _getStatusColor(syncProvider),
        ),
      ),
    );
  }

  Color _getStatusColor(SyncProvider syncProvider) {
    if (syncProvider.isSyncing) {
      return AppTheme.accentColor;
    } else if (!syncProvider.isOnline) {
      return AppTheme.errorColor;
    } else if (syncProvider.syncError != null) {
      return Colors.orange;
    } else {
      return AppTheme.successColor;
    }
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return DateFormat('dd/MM HH:mm').format(time);
    }
  }

  void _showSyncOptions(BuildContext context, SyncProvider syncProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Sincronización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado: ${syncProvider.isOnline ? "En línea" : "Sin conexión"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (syncProvider.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Última sincronización: ${DateFormat('dd/MM/yyyy HH:mm').format(syncProvider.lastSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (syncProvider.syncError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${syncProvider.syncError}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (syncProvider.isOnline && !syncProvider.isSyncing) ...[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await syncProvider.forcSync();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success 
                        ? AppTheme.successColor 
                        : AppTheme.errorColor,
                    ),
                  );
                }
              },
              child: const Text('Sincronizar Ahora'),
            ),
          ],
        ],
      ),
    );
  }
}
