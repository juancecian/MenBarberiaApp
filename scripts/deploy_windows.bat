@echo off
REM Men Barbería - Script de Despliegue Completo para Windows
REM Este script maneja todo el proceso desde setup hasta distribución

setlocal enabledelayedexpansion

REM Cambiar al directorio raíz del proyecto
cd /d "%~dp0\.."

echo.
echo ===============================================
echo   Men Barbería - Despliegue Completo Windows
echo ===============================================
echo.

:menu
echo 🎯 ¿Qué deseas hacer?
echo 1^) Setup inicial ^(configurar entorno^)
echo 2^) Build completo ^(compilar aplicación^)
echo 3^) Crear instalador ZIP
echo 4^) Build + Instalador ^(proceso completo^)
echo 5^) Solo ejecutar aplicación
echo 6^) Abrir carpeta de builds
echo 7^) Salir
echo.
set /p choice="Selecciona una opción (1-7): "

if "!choice!"=="1" goto setup
if "!choice!"=="2" goto build
if "!choice!"=="3" goto installer
if "!choice!"=="4" goto full_process
if "!choice!"=="5" goto run_app
if "!choice!"=="6" goto open_folder
if "!choice!"=="7" goto exit
echo ❌ Opción inválida. Intenta de nuevo.
goto menu

:setup
echo.
echo 🔧 Ejecutando setup inicial...
call scripts\setup_windows.bat
if %errorlevel% neq 0 (
    echo ❌ Error en setup
    pause
    goto menu
)
echo ✅ Setup completado
goto menu

:build
echo.
echo 🔨 Ejecutando build...
call scripts\build_windows.bat
if %errorlevel% neq 0 (
    echo ❌ Error en build
    pause
    goto menu
)
echo ✅ Build completado
goto menu

:installer
echo.
echo 📦 Creando instalador...
call scripts\create_windows_installer.bat
if %errorlevel% neq 0 (
    echo ❌ Error creando instalador
    pause
    goto menu
)
echo ✅ Instalador creado
goto menu

:full_process
echo.
echo 🚀 Ejecutando proceso completo...
echo.
echo [Paso 1/2] Compilando aplicación...
call scripts\build_windows.bat
if %errorlevel% neq 0 (
    echo ❌ Error en build
    pause
    goto menu
)
echo.
echo [Paso 2/2] Creando instalador...
call scripts\create_windows_installer.bat
if %errorlevel% neq 0 (
    echo ❌ Error creando instalador
    pause
    goto menu
)
echo.
echo ✅ ¡Proceso completo exitoso!
echo 📦 Tu aplicación está lista para distribución
pause
goto menu

:run_app
echo.
if exist "build\windows\x64\runner\Release\men_barberia.exe" (
    echo 🚀 Ejecutando Men Barbería...
    start "" "build\windows\x64\runner\Release\men_barberia.exe"
) else (
    echo ❌ Aplicación no encontrada. Ejecuta primero el build.
    pause
)
goto menu

:open_folder
echo.
if exist "build\windows\x64\runner\Release\" (
    echo 📁 Abriendo carpeta de builds...
    start "" "build\windows\x64\runner\Release\"
) else (
    echo ❌ Carpeta de build no encontrada. Ejecuta primero el build.
    pause
)
goto menu

:exit
echo.
echo 👋 ¡Hasta luego!
echo.
echo 📋 Scripts disponibles:
echo    • setup_windows.bat     - Configuración inicial
echo    • build_windows.bat     - Solo compilación
echo    • create_windows_installer.bat - Solo instalador
echo    • deploy_windows.bat    - Este script ^(completo^)
echo.
pause
exit /b 0
