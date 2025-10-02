@echo off
REM Men Barbería - Script de Build para Windows
REM Este script compila la aplicación para distribución en Windows

setlocal enabledelayedexpansion

REM Cambiar al directorio raíz del proyecto
cd /d "%~dp0\.."

echo.
echo ===============================================
echo   Men Barbería - Build para Windows
echo ===============================================
echo.

REM Verificar que Flutter funciona
echo [1/6] Verificando Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está disponible
    echo 💡 Ejecuta primero: setup_windows.bat
    pause
    exit /b 1
) else (
    echo ✅ Flutter verificado
)

REM Limpiar builds anteriores
echo [2/6] Limpiando builds anteriores...
flutter clean
if exist build rmdir /s /q build
echo ✅ Limpieza completada

REM Obtener dependencias
echo [3/6] Obteniendo dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error obteniendo dependencias
    pause
    exit /b 1
) else (
    echo ✅ Dependencias obtenidas
)

REM Generar iconos
echo [4/6] Generando iconos...
flutter pub run flutter_launcher_icons:main
if %errorlevel% neq 0 (
    echo ⚠️  Error generando iconos (continuando...)
) else (
    echo ✅ Iconos generados
)

REM Build para Release
echo [5/6] Compilando aplicación para Release...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ❌ Error en la compilación
    pause
    exit /b 1
) else (
    echo ✅ Compilación exitosa
)

REM Verificar resultado
echo [6/6] Verificando resultado...
if exist "build\windows\x64\runner\Release\men_barberia.exe" (
    echo ✅ ¡Build completado exitosamente!
    echo.
    echo 📍 Aplicación disponible en: build\windows\x64\runner\Release\
    echo 📊 Archivos generados:
    dir "build\windows\x64\runner\Release\" /b
    echo.
    
    REM Mostrar opciones
    echo 🎯 ¿Qué deseas hacer ahora?
    echo 1^) Ejecutar la aplicación
    echo 2^) Crear instalador ZIP
    echo 3^) Abrir carpeta de build
    echo 4^) Solo mostrar ubicación
    echo.
    set /p choice="Selecciona una opción (1-4): "
    
    if "!choice!"=="1" (
        echo 🚀 Ejecutando aplicación...
        start "" "build\windows\x64\runner\Release\men_barberia.exe"
    ) else if "!choice!"=="2" (
        echo 📦 Creando instalador ZIP...
        call scripts\create_windows_installer.bat
    ) else if "!choice!"=="3" (
        echo 📁 Abriendo carpeta...
        start "" "build\windows\x64\runner\Release\"
    ) else (
        echo 📍 La aplicación está lista en: build\windows\x64\runner\Release\men_barberia.exe
    )
    
) else (
    echo ❌ Error: Build falló - no se encontró el ejecutable
    pause
    exit /b 1
)

echo.
echo 🎉 ¡Proceso completado!
pause
