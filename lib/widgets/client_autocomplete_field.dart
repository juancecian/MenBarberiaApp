import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../models/cliente.dart';
import '../core/theme/app_theme.dart';

class ClientAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final IconData icon;
  final Function(Cliente?)? onClienteSelected;
  final String? Function(String?)? validator;

  const ClientAutocompleteField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.placeholder,
    required this.icon,
    this.onClienteSelected,
    this.validator,
  });

  @override
  State<ClientAutocompleteField> createState() => _ClientAutocompleteFieldState();
}

class _ClientAutocompleteFieldState extends State<ClientAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isShowingOverlay = false;
  Cliente? _selectedCliente;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    
    if (text.isEmpty) {
      _removeOverlay();
      _selectedCliente = null;
      widget.onClienteSelected?.call(null);
      return;
    }

    // Buscar clientes que coincidan
    final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
    clienteProvider.buscarClientes(text);
    
    // Mostrar overlay si hay texto y el campo tiene foco
    if (widget.focusNode?.hasFocus == true) {
      _showOverlay();
    }
  }

  void _onFocusChanged() {
    if (widget.focusNode?.hasFocus == true) {
      if (widget.controller.text.isNotEmpty) {
        _showOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_isShowingOverlay) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isShowingOverlay = true;
  }

  void _removeOverlay() {
    if (!_isShowingOverlay) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowingOverlay = false;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.surfaceColor,
            child: Consumer<ClienteProvider>(
              builder: (context, provider, child) {
                final sugerencias = provider.clientesSugeridos;
                
                if (sugerencias.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No se encontraron clientes',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: sugerencias.length,
                    itemBuilder: (context, index) {
                      final cliente = sugerencias[index];
                      return _buildClienteItem(cliente);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClienteItem(Cliente cliente) {
    return InkWell(
      onTap: () => _selectCliente(cliente),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (cliente.telefono != null && cliente.telefono!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      cliente.telefono!,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _selectCliente(Cliente cliente) {
    setState(() {
      _selectedCliente = cliente;
      widget.controller.text = cliente.nombre;
    });
    
    _removeOverlay();
    widget.onClienteSelected?.call(cliente);
    
    // Quitar el foco del campo
    widget.focusNode?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: _selectedCliente != null
              ? Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                )
              : null,
          filled: true,
          fillColor: AppTheme.primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.secondaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.secondaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.accentColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.errorColor,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.errorColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
