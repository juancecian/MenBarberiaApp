import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/servicio_provider.dart';
import '../core/theme/app_theme.dart';

/// Widget profesional para filtrado de servicios por fecha de registro
/// Implementa patrones de UX modernos para aplicaciones de escritorio
class DateFilterWidget extends StatefulWidget {
  const DateFilterWidget({super.key});

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicioProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con filtro actual
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.getFilterDisplayName(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Panel expandible con opciones
              if (_isExpanded) ...[
                const Divider(color: AppTheme.secondaryColor, height: 1),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar por fecha de registro:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Opciones de filtro rápido
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'Hoy',
                            isSelected: provider.currentFilter == DateFilterType.today,
                            onSelected: () => _selectFilter(provider, DateFilterType.today),
                          ),
                          _FilterChip(
                            label: 'Ayer',
                            isSelected: provider.currentFilter == DateFilterType.yesterday,
                            onSelected: () => _selectFilter(provider, DateFilterType.yesterday),
                          ),
                          _FilterChip(
                            label: 'Esta Semana',
                            isSelected: provider.currentFilter == DateFilterType.thisWeek,
                            onSelected: () => _selectFilter(provider, DateFilterType.thisWeek),
                          ),
                          _FilterChip(
                            label: 'Este Mes',
                            isSelected: provider.currentFilter == DateFilterType.thisMonth,
                            onSelected: () => _selectFilter(provider, DateFilterType.thisMonth),
                          ),
                          _FilterChip(
                            label: 'Todos',
                            isSelected: provider.currentFilter == DateFilterType.all,
                            onSelected: () => _selectFilter(provider, DateFilterType.all),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _selectFilter(ServicioProvider provider, DateFilterType filterType) {
    provider.setDateFilter(filterType);
    setState(() => _isExpanded = false);
  }
}

/// Chip personalizado para opciones de filtro
class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accentColor
                : _isHovered
                    ? AppTheme.accentColor.withOpacity(0.1)
                    : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.accentColor
                  : AppTheme.secondaryColor,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.isSelected
                  ? Colors.black87
                  : AppTheme.textPrimary,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
