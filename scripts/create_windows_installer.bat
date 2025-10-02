@echo off
REM Men Barbería - Creador de Instalador para Windows
REM Este script crea un paquete ZIP para distribución

setlocal enabledelayedexpansion

REM Cambiar al directorio raíz del proyecto
cd /d "%~dp0\.."

echo.
echo ===============================================
echo   Men Barbería - Creador de Instalador Windows
echo ===============================================
echo.

set APP_DIR=build\windows\x64\runner\Release
set INSTALLER_DIR=build\installer_windows
set ZIP_NAME=Men_Barberia_Windows_v1.0.0.zip

REM Verificar que la app existe
if not exist "%APP_DIR%\men_barberia.exe" (
    echo ❌ Error: No se encontró la aplicación en %APP_DIR%
    echo 💡 Ejecuta primero: build_windows.bat
    pause
    exit /b 1
)

REM Limpiar directorio anterior
echo [1/5] Preparando instalador...
if exist "%INSTALLER_DIR%" rmdir /s /q "%INSTALLER_DIR%"
mkdir "%INSTALLER_DIR%"

REM Copiar aplicación y dependencias
echo [2/5] Copiando archivos de la aplicación...
xcopy "%APP_DIR%\*" "%INSTALLER_DIR%\" /E /I /Y
if %errorlevel% neq 0 (
    echo ❌ Error copiando archivos
    pause
    exit /b 1
) else (
    echo ✅ Archivos copiados correctamente
)

REM Crear archivo de instrucciones
echo [3/5] Creando archivo de instrucciones...
(
echo Men Barbería - Aplicación de Gestión para Barbería
echo ================================================
echo.
echo INSTALACIÓN:
echo 1. Extrae todos los archivos a una carpeta en tu PC
echo 2. Ejecuta "men_barberia.exe" para iniciar la aplicación
echo 3. La primera vez, Windows puede mostrar una advertencia de seguridad
echo    - Haz clic en "Más información" y luego "Ejecutar de todas formas"
echo.
echo REQUISITOS:
echo • Windows 10 o superior
echo • 200 MB de espacio libre
echo • Visual C++ Redistributable ^(se instala automáticamente^)
echo.
echo DESINSTALACIÓN:
echo • Simplemente elimina la carpeta donde extrajiste los archivos
echo.
echo SOPORTE:
echo • Para soporte técnico, contacta al desarrollador
echo • Versión: 1.0.0
echo.
echo © 2025 Men Barbería Solutions
echo Todos los derechos reservados
) > "%INSTALLER_DIR%\LEEME.txt"

REM Crear script de ejecución
echo [4/5] Creando script de ejecución...
(
echo @echo off
echo REM Men Barbería - Ejecutor
echo cd /d "%%~dp0"
echo start "" "men_barberia.exe"
) > "%INSTALLER_DIR%\Ejecutar_Men_Barberia.bat"

REM Crear archivo ZIP
echo [5/5] Creando archivo ZIP...
if exist "%ZIP_NAME%" del "%ZIP_NAME%"

REM Usar PowerShell para crear ZIP
powershell -command "Compress-Archive -Path '%INSTALLER_DIR%\*' -DestinationPath '%ZIP_NAME%' -CompressionLevel Optimal"
if %errorlevel% neq 0 (
    echo ❌ Error creando archivo ZIP
    pause
    exit /b 1
)

REM Verificar resultado
if exist "%ZIP_NAME%" (
    echo ✅ ¡Instalador creado exitosamente!
    echo.
    echo 📍 Ubicación: %ZIP_NAME%
    for %%A in ("%ZIP_NAME%") do echo 📊 Tamaño: %%~zA bytes
    echo.
    echo 🎉 El instalador está listo para distribución:
    echo    • Los usuarios descomprimen el ZIP
    echo    • Ejecutan "men_barberia.exe" o "Ejecutar_Men_Barberia.bat"
    echo    • Incluye todas las dependencias necesarias
    echo    • Funciona sin instalación adicional
    echo.
    
    set /p open="¿Deseas abrir la carpeta del instalador? (s/N): "
    if /i "!open!"=="s" (
        start "" "%cd%"
    )
    
) else (
    echo ❌ Error: La creación del instalador falló
    pause
    exit /b 1
)

echo.
echo 🎉 ¡Instalador Windows completado!
pause
