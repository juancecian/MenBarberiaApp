# 🔄 Sistema de Actualizaciones Automáticas - Men Barbería

## Descripción

La aplicación Men Barbería ahora incluye un sistema de actualizaciones automáticas que permite:

- ✅ **Verificación automática** de nuevas versiones al iniciar
- ✅ **Notificaciones visuales** cuando hay actualizaciones disponibles  
- ✅ **Descarga e instalación** automática de actualizaciones
- ✅ **Soporte multiplataforma** (Windows, macOS, Linux)
- ✅ **Configuración de preferencias** de actualización

## Componentes Implementados

### 1. **UpdateService** (`lib/services/update_service.dart`)
Servicio principal que maneja:
- Verificación de actualizaciones desde GitHub Releases
- Descarga e instalación de nuevas versiones
- Configuración de preferencias del usuario
- Manejo de errores y logging

### 2. **UpdateNotificationWidget** (`lib/widgets/update_notification_widget.dart`)
Widget de interfaz que incluye:
- **UpdateNotificationWidget**: Notificación flotante en el dashboard
- **UpdateSettingsWidget**: Panel de configuración para las actualizaciones

### 3. **Scripts de Build** (`scripts/build_release.sh`)
Script automatizado para:
- Generar builds de release para múltiples plataformas
- Crear archivos de distribución (ZIP, DMG, TAR.GZ)
- Preparar releases para GitHub

## Configuración Inicial

### 1. **Actualizar información del repositorio**

Edita `lib/services/update_service.dart` línea 13:
```dart
static const String _githubRepo = 'tu-usuario/men-barberia'; // ⚠️ CAMBIAR
```

### 2. **Configurar versión actual**

Actualiza `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Incrementar para nuevas versiones
```

### 3. **Instalar dependencias**

```bash
flutter pub get
```

## Uso del Sistema

### **Para Usuarios**

1. **Verificación automática**: La app verifica actualizaciones al iniciar
2. **Notificación visual**: Aparece una tarjeta cuando hay actualizaciones
3. **Instalación fácil**: Un clic en "Actualizar ahora" descarga e instala
4. **Configuración**: Acceso a preferencias en el menú de configuración

### **Para Desarrolladores**

#### **Crear un nuevo release:**

1. **Incrementar versión** en `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Nueva versión
   ```

2. **Generar builds**:
   ```bash
   ./scripts/build_release.sh 1.0.1
   ```

3. **Crear release en GitHub**:
   - Ir a GitHub → Releases → New Release
   - Tag: `v1.0.1`
   - Título: `Men Barbería v1.0.1`
   - Subir archivos de `dist/`

4. **Publicar release** para activar las actualizaciones

## Estructura de Archivos

```
men_barberia/
├── lib/
│   ├── services/
│   │   └── update_service.dart          # Servicio principal
│   └── widgets/
│       └── update_notification_widget.dart  # UI de notificaciones
├── scripts/
│   └── build_release.sh                 # Script de build
├── update_config.json                   # Configuración
└── ACTUALIZACIONES.md                   # Esta documentación
```

## Configuración Avanzada

### **Personalizar intervalo de verificación**

En `UpdateService.checkForUpdatesOnStartup()`:
```dart
await Future.delayed(const Duration(seconds: 5)); // Cambiar delay
```

### **Modificar fuente de actualizaciones**

En `UpdateService._updateUrl`:
```dart
static const String _updateUrl = 'https://api.github.com/repos/tu-repo/releases/latest';
```

### **Configurar canales de release**

Editar `update_config.json` para manejar versiones beta/estable.

## Solución de Problemas

### **Las actualizaciones no aparecen**
- ✅ Verificar que `_githubRepo` esté configurado correctamente
- ✅ Confirmar que hay releases públicos en GitHub
- ✅ Revisar logs en consola para errores

### **Error de descarga**
- ✅ Verificar conexión a internet
- ✅ Confirmar permisos de escritura en el directorio de la app
- ✅ Revisar que los archivos de release estén disponibles

### **Modo Debug**
- ⚠️ Las actualizaciones solo funcionan en **builds de release**
- ⚠️ En modo debug se simula el comportamiento para testing

## Próximas Mejoras

- [ ] **Verificación de checksums** para integridad de archivos
- [ ] **Actualizaciones incrementales** para reducir tamaño de descarga
- [ ] **Rollback automático** en caso de errores
- [ ] **Notificaciones push** para actualizaciones críticas
- [ ] **Programación de actualizaciones** para horarios específicos

## Seguridad

- 🔒 **Verificación de firma**: Los releases deben estar firmados
- 🔒 **HTTPS obligatorio**: Solo descargas desde conexiones seguras  
- 🔒 **Validación de versión**: Previene downgrades maliciosos
- 🔒 **Permisos mínimos**: Solo acceso necesario al sistema de archivos

---

**Nota**: Este sistema está diseñado para aplicaciones de escritorio. Para distribución en tiendas de aplicaciones (Microsoft Store, Mac App Store), se requieren configuraciones adicionales específicas de cada plataforma.
