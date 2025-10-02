import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/barbero_provider.dart';
import '../models/servicio_model.dart';
import '../models/barbero.dart';
import '../core/theme/app_theme.dart';
import '../core/services/supabase_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  
  DateTime _selectedDate = DateTime.now();
  List<Servicio> _servicios = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiciosForDate();
    });
  }

  Future<void> _loadServiciosForDate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
      
      final servicios = await SupabaseService().getServiciosPorFecha(startOfDay, endOfDay);
      
      setState(() {
        _servicios = servicios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar servicios: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.black,
              surface: AppTheme.primaryColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadServiciosForDate();
    }
  }

  Map<String, dynamic> _calculateMetrics() {
    double totalRecaudado = 0;
    int totalServicios = _servicios.length;
    Map<String, int> serviciosPorBarbero = {};
    Map<String, double> recaudadoPorBarbero = {};

    for (final servicio in _servicios) {
      totalRecaudado += servicio.price;
      
      final barberoId = servicio.barberId;
      serviciosPorBarbero[barberoId] = (serviciosPorBarbero[barberoId] ?? 0) + 1;
      recaudadoPorBarbero[barberoId] = (recaudadoPorBarbero[barberoId] ?? 0) + servicio.price;
    }

    return {
      'totalRecaudado': totalRecaudado,
      'totalServicios': totalServicios,
      'serviciosPorBarbero': serviciosPorBarbero,
      'recaudadoPorBarbero': recaudadoPorBarbero,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Calcular métricas una sola vez para evitar recálculos
    final metrics = _isLoading ? null : _calculateMetrics();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricsCards(metrics),
                  const SizedBox(height: 10),
                  _buildServiciosList(metrics),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Servicios del ${_displayDateFormat.format(_selectedDate)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Cambiar Fecha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMetricsCards(Map<String, dynamic>? metrics) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
            TextButton(
              onPressed: _loadServiciosForDate,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (metrics == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _MetricCard(
            title: 'Total Recaudado',
            value: '\$${metrics['totalRecaudado'].toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _MetricCard(
            title: 'Total Servicios',
            value: '${metrics['totalServicios']}',
            icon: Icons.content_cut,
            color: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }


  Widget _buildServiciosList(Map<String, dynamic>? metrics) {
    if (metrics == null) {
      return const Expanded(child: SizedBox.shrink());
    }
    
    final serviciosPorBarbero = metrics['serviciosPorBarbero'] as Map<String, int>;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Servicios por Barbero',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                      ),
                    )
                  else
                    Text(
                      '${_servicios.length} servicios • ${serviciosPorBarbero.length} barberos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: AppTheme.secondaryColor, height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                      ),
                    )
                  : _servicios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.content_cut_outlined,
                                size: 64,
                                color: AppTheme.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay servicios registrados',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Selecciona otra fecha para ver los servicios',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _BarberoAccordionList(
                          serviciosPorBarbero: serviciosPorBarbero,
                          servicios: _servicios,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _BarberoAccordionList extends StatefulWidget {
  final Map<String, int> serviciosPorBarbero;
  final List<Servicio> servicios;

  const _BarberoAccordionList({
    required this.serviciosPorBarbero,
    required this.servicios,
  });

  @override
  State<_BarberoAccordionList> createState() => _BarberoAccordionListState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        }
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  widget.value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarberoAccordionListState extends State<_BarberoAccordionList> {
  final Set<String> _expandedBarberos = {};

  List<Servicio> _getServiciosPorBarbero(String barberoId) {
    return widget.servicios.where((servicio) => servicio.barberId == barberoId).toList()
      ..sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarberoProvider>(
      builder: (context, barberoProvider, child) {
        if (widget.serviciosPorBarbero.isEmpty) {
          return const Center(
            child: Text(
              'No hay servicios para mostrar',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        // Ordenar barberos por cantidad de servicios (descendente)
        final barberosOrdenados = widget.serviciosPorBarbero.entries
            .toList()
            ..sort((a, b) => b.value.compareTo(a.value));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: barberosOrdenados.length,
          itemBuilder: (context, index) {
            final entry = barberosOrdenados[index];
            final barbero = barberoProvider.barberos
                .where((b) => b.id == entry.key)
                .firstOrNull;
            final isExpanded = _expandedBarberos.contains(entry.key);
            final serviciosBarbero = _getServiciosPorBarbero(entry.key);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header del accordion
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedBarberos.remove(entry.key);
                        } else {
                          _expandedBarberos.add(entry.key);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Avatar del barbero
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Información del barbero
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  barbero?.nombre ?? 'Desconocido',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entry.value} servicio${entry.value != 1 ? 's' : ''} realizados',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Badge con total recaudado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '\$${serviciosBarbero.fold(0.0, (sum, s) => sum + s.price).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Flecha de expansión
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.textSecondary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Contenido expandible
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isExpanded
                        ? Container(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(color: AppTheme.secondaryColor, height: 1),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: serviciosBarbero.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                                      itemBuilder: (context, index) {
                                        final servicio = serviciosBarbero[index];
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceColor.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              // Icono del servicio
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(
                                                  Icons.content_cut,
                                                  color: AppTheme.accentColor,
                                                  size: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Información del servicio
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      servicio.clientName,
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.textPrimary,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.accentBlue.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          child: Text(
                                                            _getTipoServicioNombre(servicio.typeService),
                                                            style: TextStyle(
                                                              color: AppTheme.accentBlue,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          DateFormat('HH:mm').format(servicio.registrationDate),
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: AppTheme.textSecondary,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Precio
                                              Text(
                                                '\$${servicio.price.toStringAsFixed(0)}',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.successColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTipoServicioNombre(int tipoId) {
    switch (tipoId) {
      case 1:
        return 'Corte';
      case 2:
        return 'Barba';
      case 3:
        return 'Corte + Barba';
      case 4:
        return 'Afeitado';
      default:
        return 'Servicio';
    }
  }
}

class _ServicioCard extends StatefulWidget {
  final Servicio servicio;

  const _ServicioCard({
    required this.servicio,
  });

  @override
  State<_ServicioCard> createState() => _ServicioCardState();
}

class _ServicioCardState extends State<_ServicioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        }
      },  
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.servicio.clientName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTipoServicioNombre(widget.servicio.typeService),
                              style: TextStyle(
                                color: AppTheme.accentBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Consumer<BarberoProvider>(
                        builder: (context, provider, child) {
                          final barbero = provider.barberos
                              .where((b) => b.id == widget.servicio.barberId)
                              .firstOrNull;
                          return Text(
                            'Barbero: ${barbero?.nombre ?? 'Desconocido'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(widget.servicio.registrationDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.servicio.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTipoServicioNombre(int tipoId) {
    switch (tipoId) {
      case 1:
        return 'Corte';
      case 2:
        return 'Barba';
      case 3:
        return 'Corte + Barba';
      case 4:
        return 'Afeitado';
      default:
        return 'Servicio';
    }
  }
}
