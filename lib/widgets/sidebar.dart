import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../core/theme/app_theme.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final isCollapsed = navigationProvider.isCollapsed;
        final width = isCollapsed ? 80.0 : 280.0;

        return Container(
          width: width,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isCollapsed ? 0.05 : 0.1),
                  blurRadius: isCollapsed ? 5 : 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context, navigationProvider),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildNavigationItems(context, navigationProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, NavigationProvider navigationProvider) {
    final isCollapsed = navigationProvider.isCollapsed;

    return Container(
      padding: EdgeInsets.all(isCollapsed ? 8 : 20),
      child: Row(
        children: [
          if (isCollapsed) ...[
            // Cuando está colapsado: solo icono centrado con cursor pointer
            Expanded(
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => navigationProvider.toggleSidebar(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Cuando está expandido: layout original
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.content_cut,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Men Barbería',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Sistema de Gestión',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isCollapsed)
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => navigationProvider.toggleSidebar(),
                icon: const Icon(
                  Icons.menu,
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
                tooltip: 'Colapsar sidebar',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, NavigationProvider navigationProvider) {
    final items = [
      _NavigationItemData(
        item: NavigationItem.inicio,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        title: 'Inicio',
      ),
      _NavigationItemData(
        item: NavigationItem.barberos,
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        title: 'Barberos',
      ),
      _NavigationItemData(
        item: NavigationItem.historial,
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        title: 'Historial',
      ),
      _NavigationItemData(
        item: NavigationItem.configuracion,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        title: 'Configuración',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _NavigationItem(
          data: items[index],
          navigationProvider: navigationProvider,
        );
      },
    );
  }

  Widget _buildFooter(bool isCollapsed) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 12 : 20),
      child: Column(
        children: [
          const Divider(color: AppTheme.secondaryColor),
          SizedBox(height: isCollapsed ? 8 : 16),
          if (!isCollapsed) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                ),

              ],
            ),
          ] else ...[
            CircleAvatar(
              radius: isCollapsed ? 16 : 20,
              backgroundColor: AppTheme.accentColor,
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: isCollapsed ? 16 : 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationItemData {
  final NavigationItem item;
  final IconData icon;
  final IconData activeIcon;
  final String title;

  _NavigationItemData({
    required this.item,
    required this.icon,
    required this.activeIcon,
    required this.title,
  });
}

class _NavigationItem extends StatefulWidget {
  final _NavigationItemData data;
  final NavigationProvider navigationProvider;

  const _NavigationItem({
    required this.data,
    required this.navigationProvider,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
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
    final isActive = widget.navigationProvider.currentItem == widget.data.item;
    final isCollapsed = widget.navigationProvider.isCollapsed;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
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
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentColor.withOpacity(0.15)
                : _isHovered
                    ? AppTheme.secondaryColor.withOpacity(0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppTheme.accentColor.withOpacity(0.3))
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                widget.navigationProvider.setCurrentItem(widget.data.item);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 12 : 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      isActive ? widget.data.activeIcon : widget.data.icon,
                      color: isActive
                          ? AppTheme.accentColor
                          : AppTheme.textPrimary,
                      size: isCollapsed ? 20 : 24,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.data.title,
                          style: TextStyle(
                            color: isActive
                                ? AppTheme.accentColor
                                : AppTheme.textPrimary,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}