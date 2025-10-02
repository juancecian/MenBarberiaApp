@echo off
REM Men Barbería - Script de Configuración para Windows
REM Este script prepara el entorno de desarrollo en Windows

echo.
echo ===============================================
echo   Men Barbería - Setup para Windows
echo ===============================================
echo.

REM Verificar si Flutter está instalado
echo [1/5] Verificando Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado
    echo.
    echo 💡 Instala Flutter desde: https://docs.flutter.dev/get-started/install/windows
    echo    1. Descarga Flutter SDK
    echo    2. Extrae a C:\flutter
    echo    3. Agrega C:\flutter\bin al PATH
    echo    4. Ejecuta 'flutter doctor' para verificar
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Flutter encontrado
)

REM Verificar Visual Studio
echo [2/5] Verificando Visual Studio Build Tools...
where cl >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Visual Studio Build Tools no encontrado
    echo.
    echo 💡 Instala Visual Studio Build Tools:
    echo    1. Ve a: https://visualstudio.microsoft.com/downloads/
    echo    2. Descarga "Build Tools for Visual Studio"
    echo    3. Instala con "C++ build tools" seleccionado
    echo.
    echo 🔄 Continuando sin verificación completa...
) else (
    echo ✅ Visual Studio Build Tools encontrado
)

REM Habilitar soporte para Windows
echo [3/5] Habilitando soporte para Windows...
flutter config --enable-windows-desktop
if %errorlevel% neq 0 (
    echo ❌ Error habilitando soporte para Windows
    pause
    exit /b 1
) else (
    echo ✅ Soporte para Windows habilitado
)

REM Verificar configuración
echo [4/5] Verificando configuración completa...
flutter doctor
echo.

REM Obtener dependencias
echo [5/5] Obteniendo dependencias del proyecto...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error obteniendo dependencias
    pause
    exit /b 1
) else (
    echo ✅ Dependencias obtenidas correctamente
)

echo.
echo ✅ ¡Configuración completada!
echo.
echo 📋 Próximos pasos:
echo    1. Ejecuta 'build_windows.bat' para compilar
echo    2. O usa 'deploy_windows.bat' para build + instalador
echo.
pause
