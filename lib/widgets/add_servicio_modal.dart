import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/servicio_provider.dart';
import '../providers/barbero_provider.dart';
import '../models/servicio.dart';
import '../core/theme/app_theme.dart';
import 'simple_input.dart';
import 'simple_selectors.dart';
import 'desktop_button.dart';

class AddServicioModal extends StatefulWidget {
  const AddServicioModal({super.key});

  @override
  State<AddServicioModal> createState() => _AddServicioModalState();
}

class _AddServicioModalState extends State<AddServicioModal> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _precioController = TextEditingController();
  final _propinaController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  // Focus nodes for manual focus management
  final _clienteFocusNode = FocusNode();
  final _precioFocusNode = FocusNode();
  
  DateTime _fechaSeleccionada = DateTime.now();
  late String _horaSeleccionada;
  String? _barberoSeleccionado;
  String? _tipoServicioSeleccionado;
  int _tipoPagoSeleccionado = 1; // 1 = Efectivo por defecto

  @override
  void initState() {
    super.initState();
    // Establecer la hora actual como hora por defecto
    final now = DateTime.now();
    _horaSeleccionada = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _loadBarberos();
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _telefonoController.dispose();
    _precioController.dispose();
    _propinaController.dispose();
    _observacionesController.dispose();
    _clienteFocusNode.dispose();
    _precioFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBarberos() async {
    final provider = Provider.of<BarberoProvider>(context, listen: false);
    await provider.loadBarberos();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 650,
        height: 750,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Servicio',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registra un nuevo servicio de barbería',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Information Section
                        Text(
                          'Información del Cliente',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SimpleInput(
                                controller: _clienteController,
                                focusNode: _clienteFocusNode,
                                placeholder: 'Nombre del cliente',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre del cliente es requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SimpleInput(
                                controller: _telefonoController,
                                placeholder: 'Teléfono (opcional)',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Service Information Section
                        Text(
                          'Detalles del Servicio',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SimpleDropdown<String>(
                                value: _tipoServicioSeleccionado,
                                placeholder: 'Tipo de servicio',
                                icon: Icons.content_cut_outlined,
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'Corte',
                                    child: Text(
                                      'Corte',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Corte + Barba',
                                    child: Text(
                                      'Corte + Barba',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Tintura',
                                    child: Text(
                                      'Tintura',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _tipoServicioSeleccionado = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecciona un tipo de servicio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SimpleInput(
                                controller: _precioController,
                                focusNode: _precioFocusNode,
                                placeholder: 'Precio del servicio',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El precio es requerido';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Ingresa un precio válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Scheduling Section
                        Text(
                          'Programación',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<BarberoProvider>(
                                builder: (context, provider, child) {
                                  return SimpleDropdown<String>(
                                    value: _barberoSeleccionado,
                                    placeholder: 'Seleccionar barbero',
                                    icon: Icons.person_outline,
                                    items: provider.barberos.map((barbero) {
                                      return DropdownMenuItem<String>(
                                        value: barbero.id,
                                        child: Text(
                                          barbero.nombre,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _barberoSeleccionado = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Selecciona un barbero';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SimpleDateSelector(
                                selectedDate: _fechaSeleccionada,
                                placeholder: 'Fecha del servicio',
                                icon: Icons.calendar_today_outlined,
                                onDateSelected: (date) {
                                  setState(() {
                                    _fechaSeleccionada = date;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: SimpleTimeSelector(
                                selectedTime: _horaSeleccionada,
                                placeholder: 'Hora del servicio',
                                icon: Icons.access_time_outlined,
                                onTimeSelected: (time) {
                                  setState(() {
                                    _horaSeleccionada = time;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SimpleInput(
                                controller: _propinaController,
                                placeholder: 'Propina (opcional)',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Payment Type Section
                        Text(
                          'Tipo de Pago',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPaymentTypeOption(
                                value: 1,
                                title: 'Efectivo',
                                icon: Icons.money,
                                isSelected: _tipoPagoSeleccionado == 1,
                                onTap: () {
                                  setState(() {
                                    _tipoPagoSeleccionado = 1;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPaymentTypeOption(
                                value: 2,
                                title: 'Transferencia',
                                icon: Icons.account_balance,
                                isSelected: _tipoPagoSeleccionado == 2,
                                onTap: () {
                                  setState(() {
                                    _tipoPagoSeleccionado = 2;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: DesktopButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                                label: 'Cancelar',
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DesktopButton(
                                onPressed: _saveService,
                                icon: const Icon(Icons.save),
                                label: 'Guardar Servicio',
                                isPrimary: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeOption({
    required int value,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Definir colores específicos para cada tipo de pago
    final Color selectedColor = value == 1 
        ? AppTheme.successColor  // Verde para efectivo
        : AppTheme.accentBlue;   // Azul para transferencia
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? selectedColor.withOpacity(0.1)
              : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? selectedColor
                : AppTheme.secondaryColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? selectedColor
                    : AppTheme.secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white
                    : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected 
                      ? selectedColor
                      : AppTheme.textPrimary,
                  fontWeight: isSelected 
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: selectedColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    // Manual validation to focus on first error field
    if (_clienteController.text.trim().isEmpty) {
      _clienteFocusNode.requestFocus();
      return;
    }
    
    if (_tipoServicioSeleccionado == null) {
      // Show a brief message for dropdown since we can't focus it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de servicio'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (_precioController.text.trim().isEmpty || double.tryParse(_precioController.text) == null) {
      _precioFocusNode.requestFocus();
      return;
    }

    if (_barberoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un barbero'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Crear el objeto Servicio
    // Crear DateTime combinando fecha y hora seleccionadas
    final fechaHora = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      int.parse(_horaSeleccionada.split(':')[0]),
      int.parse(_horaSeleccionada.split(':')[1]),
    );

    final servicio = Servicio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      barberoId: _barberoSeleccionado!,
      clienteNombre: _clienteController.text.trim(),
      clienteTelefono: _telefonoController.text.trim().isEmpty 
          ? null 
          : _telefonoController.text.trim(),
      tipoServicio: _getTipoServicioId(_tipoServicioSeleccionado!),
      precioServicio: double.tryParse(_precioController.text) ?? 0,
      propina: double.tryParse(_propinaController.text) ?? 0,
      tipoPago: _tipoPagoSeleccionado,
      registrationDate: fechaHora,
    );

    // Cerrar el teclado
    FocusScope.of(context).unfocus();

    try {
      final provider = Provider.of<ServicioProvider>(context, listen: false);
      final success = await provider.addServicio(servicio);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio agregado correctamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error ?? "Error desconocido"}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  int _getTipoServicioId(String tipoNombre) {
    switch (tipoNombre) {
      case 'Corte':
        return 1;
      case 'Barba':
        return 2;
      case 'Corte + Barba':
        return 3;
      case 'Tintura':
        return 4;
      default:
        return 1;
    }
  }
}