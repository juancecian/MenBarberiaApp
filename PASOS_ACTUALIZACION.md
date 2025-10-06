# 📦 Guía Completa: Enviar Actualización a Apps Instaladas

## 🎯 Proceso Paso a Paso

### **PASO 1: Preparar la Nueva Versión**

1. **Incrementar versión en `pubspec.yaml`:**
   ```yaml
   version: 1.0.1+2  # Formato: MAJOR.MINOR.PATCH+BUILD_NUMBER
   ```

2. **Actualizar versión en `update_service.dart`:**
   ```dart
   String getCurrentVersion() {
     return '1.0.1'; // Debe coincidir con pubspec.yaml
   }
   ```

3. **Documentar cambios** (opcional pero recomendado):
   - Crear entrada en CHANGELOG.md
   - Documentar nuevas características y correcciones

### **PASO 2: Generar Builds de Release**

```bash
# Limpiar proyecto
flutter clean
flutter pub get

# Generar builds para todas las plataformas
./scripts/build_release.sh 1.0.1

# O generar para plataforma específica
./scripts/build_release.sh 1.0.1 windows
./scripts/build_release.sh 1.0.1 macos
./scripts/build_release.sh 1.0.1 linux
```

**Archivos generados en `dist/`:**
- `men_barberia_v1.0.1_windows.zip`
- `men_barberia_v1.0.1_macos.dmg` (o .zip)
- `men_barberia_v1.0.1_linux.tar.gz`

### **PASO 3: Crear Release en GitHub**

1. **Ir a GitHub Repository:**
   - https://github.com/juancecian/MenBarberiaApp
   - Clic en "Releases" → "Create a new release"

2. **Configurar Release:**
   ```
   Tag version: v1.0.1
   Release title: Men Barbería v1.0.1
   Target: main branch
   ```

3. **Descripción del Release:**
   ```markdown
   ## 🚀 Men Barbería v1.0.1
   
   ### ✨ Nuevas Características
   - Sistema de actualizaciones automáticas
   - Mejoras en la interfaz de usuario
   
   ### 🐛 Correcciones
   - Corrección de errores menores
   - Mejoras de rendimiento
   
   ### 📥 Descargas
   - Windows: men_barberia_v1.0.1_windows.zip
   - macOS: men_barberia_v1.0.1_macos.dmg
   - Linux: men_barberia_v1.0.1_linux.tar.gz
   ```

4. **Subir Archivos:**
   - Arrastrar los archivos de `dist/` a la sección "Attach binaries"
   - Verificar que los nombres coincidan con `app-archive.json`

5. **Publicar Release:**
   - ✅ Marcar "Set as the latest release"
   - Clic en "Publish release"

### **PASO 4: Actualizar app-archive.json**

```json
{
  "appName": "Men Barbería",
  "description": "Aplicación de gestión para barbería",
  "items": [
    {
      "version": "1.0.1",
      "shortVersion": 2,
      "changes": [
        {
          "type": "feat",
          "message": "Sistema de actualizaciones automáticas"
        },
        {
          "type": "fix", 
          "message": "Corrección de errores menores"
        }
      ],
      "date": "2024-10-06",
      "mandatory": false,
      "url": "https://github.com/juancecian/MenBarberiaApp/releases/download/v1.0.1/men_barberia_v1.0.1_windows.zip",
      "platform": "windows"
    }
    // ... repetir para macOS y Linux
  ]
}
```

### **PASO 5: Subir app-archive.json a GitHub**

```bash
# Commit y push del archivo actualizado
git add app-archive.json
git commit -m "feat: actualizar app-archive.json para v1.0.1"
git push origin main
```

### **PASO 6: Verificar URLs**

**Verificar que estas URLs respondan correctamente:**
- `https://raw.githubusercontent.com/juancecian/MenBarberiaApp/main/app-archive.json`
- `https://github.com/juancecian/MenBarberiaApp/releases/download/v1.0.1/men_barberia_v1.0.1_windows.zip`

## 🔄 ¿Cómo Funciona la Actualización Automática?

### **En la App Instalada:**

1. **Verificación Automática:**
   - La app verifica actualizaciones al iniciar
   - Consulta: `app-archive.json` cada 24 horas (configurable)

2. **Detección de Actualización:**
   - Compara versión local vs. versión en `app-archive.json`
   - Si hay nueva versión → Muestra notificación

3. **Proceso de Actualización:**
   - Usuario hace clic en "Actualizar ahora"
   - Descarga el archivo desde GitHub Releases
   - Instala automáticamente
   - Reinicia la aplicación

### **Flujo Técnico:**

```
App Instalada (v1.0.0)
    ↓
Consulta app-archive.json
    ↓
Encuentra v1.0.1 disponible
    ↓
Muestra notificación al usuario
    ↓
Usuario acepta actualización
    ↓
Descarga desde GitHub Releases
    ↓
Instala nueva versión
    ↓
Reinicia app con v1.0.1
```

## ⚡ Comandos Rápidos

```bash
# Proceso completo automatizado
./scripts/release_update.sh 1.0.1 "Sistema de actualizaciones automáticas"
```

## 🔒 Consideraciones de Seguridad

- **Firmar ejecutables** para evitar advertencias de seguridad
- **Usar HTTPS** para todas las descargas
- **Verificar checksums** de archivos descargados
- **Validar certificados** SSL durante la descarga

## 📊 Monitoreo de Actualizaciones

- **GitHub Analytics:** Ver descargas de releases
- **Logs de aplicación:** Verificar actualizaciones exitosas
- **Feedback de usuarios:** Reportes de problemas

---

**⚠️ Importante:** Siempre probar el proceso de actualización en un entorno de pruebas antes de publicar a producción.
