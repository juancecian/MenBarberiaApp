# Men Barbería - Compilación en Windows

## 📋 Requisitos Previos

### 1. **Flutter SDK**
- Descarga desde: https://docs.flutter.dev/get-started/install/windows
- Extrae a `C:\flutter`
- Agrega `C:\flutter\bin` al PATH del sistema
- Ejecuta `flutter doctor` para verificar

### 2. **Visual Studio Build Tools**
- Descarga desde: https://visualstudio.microsoft.com/downloads/
- Instala "Build Tools for Visual Studio 2022"
- Selecciona "C++ build tools" durante la instalación
- Reinicia la PC después de la instalación

### 3. **Git** (opcional)
- Para clonar el repositorio si no tienes los archivos

## 🚀 Proceso de Compilación

### **Opción 1: Proceso Automático (Recomendado)**
```cmd
# 1. Abrir Command Prompt o PowerShell
# 2. Navegar a la carpeta del proyecto
cd ruta\a\menbarberia

# 3. Ejecutar script maestro
scripts\deploy_windows.bat
```

### **Opción 2: Paso a Paso**
```cmd
# 1. Setup inicial (solo la primera vez)
scripts\setup_windows.bat

# 2. Compilar aplicación
scripts\build_windows.bat

# 3. Crear instalador (opcional)
scripts\create_windows_installer.bat
```

## 📦 Archivos Generados

### **Aplicación Compilada:**
- **Ubicación:** `build\windows\x64\runner\Release\`
- **Ejecutable:** `men_barberia.exe`
- **Dependencias:** Todas las DLLs necesarias incluidas

### **Instalador para Distribución:**
- **Archivo:** `Men_Barberia_Windows_v1.0.0.zip`
- **Contenido:** Aplicación + dependencias + instrucciones
- **Tamaño:** ~50-80 MB (aproximado)

## 🔧 Solución de Problemas

### **Error: Flutter no encontrado**
```cmd
# Verificar instalación
flutter --version

# Si no funciona, agregar al PATH:
# C:\flutter\bin
```

### **Error: Visual Studio Build Tools**
```cmd
# Verificar instalación
where cl

# Si no funciona, reinstalar Build Tools con C++ support
```

### **Error: Dependencias**
```cmd
# Limpiar y reinstalar
flutter clean
flutter pub get
```

### **Error: Permisos**
```cmd
# Ejecutar Command Prompt como Administrador
# Especialmente para la primera compilación
```

## 📱 Distribución

### **Para Usuarios Finales:**
1. Envía el archivo `Men_Barberia_Windows_v1.0.0.zip`
2. El usuario extrae el ZIP a cualquier carpeta
3. Ejecuta `men_barberia.exe` o `Ejecutar_Men_Barberia.bat`
4. Windows puede mostrar advertencia de seguridad (normal)

### **Advertencia de Windows Defender:**
- Es normal para aplicaciones no firmadas
- El usuario debe hacer clic en "Más información" → "Ejecutar de todas formas"
- Para evitar esto, necesitarías un certificado de firma de código (pago)

## 🎯 Flujo Completo Recomendado

```cmd
# En la PC Windows:
1. Instalar Flutter + Visual Studio Build Tools
2. Copiar/clonar el proyecto Men Barbería
3. Ejecutar: scripts\deploy_windows.bat
4. Seleccionar opción 4 (Build + Instalador)
5. Distribuir el archivo ZIP generado
```

## 📞 Soporte

Si encuentras problemas:
1. Verifica que `flutter doctor` no muestre errores
2. Asegúrate de tener Visual Studio Build Tools instalado
3. Ejecuta los scripts como Administrador si es necesario
4. Revisa que todas las dependencias estén en `pubspec.yaml`

¡La aplicación debería compilar sin problemas siguiendo estos pasos!
