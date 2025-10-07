# Script para crear releases de la aplicacion Men Barberia en Windows (PowerShell)
# Uso: .\build_release_fixed.ps1 [version] [platform]
# Este script funciona desde cualquier ubicacion

param(
    [string]$Version = "1.0.0",
    [string]$Platform = "all"
)

$APP_NAME = "men_barberia"
$ErrorActionPreference = "Stop"

# Obtener el directorio del script y cambiar al directorio raíz del proyecto
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "Iniciando build de release v$Version para $Platform" -ForegroundColor Green
Write-Host "Directorio del proyecto: $ProjectRoot" -ForegroundColor Cyan

# Cambiar al directorio raíz del proyecto
Set-Location $ProjectRoot

# Verificar que estamos en el directorio correcto
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "Error: No se encontro pubspec.yaml en el directorio actual" -ForegroundColor Red
    Write-Host "Directorio actual: $(Get-Location)" -ForegroundColor Red
    exit 1
}

# Limpiar builds anteriores
Write-Host "Limpiando builds anteriores..." -ForegroundColor Yellow
try {
    flutter clean
    flutter pub get
    Write-Host "Limpieza completada" -ForegroundColor Green
} catch {
    Write-Host "Error al limpiar o obtener dependencias: $_" -ForegroundColor Red
    exit 1
}

# Crear directorio dist si no existe
$distPath = Join-Path $ProjectRoot "dist"
if (!(Test-Path $distPath)) {
    New-Item -ItemType Directory -Path $distPath -Force | Out-Null
    Write-Host "Directorio 'dist' creado en: $distPath" -ForegroundColor Green
}

# Función para build de Windows
function Build-Windows {
    Write-Host "Building para Windows..." -ForegroundColor Yellow
    
    try {
        flutter build windows --release
        Write-Host "Build de Windows completado" -ForegroundColor Green
    } catch {
        Write-Host "Error en build de Windows: $_" -ForegroundColor Red
        exit 1
    }
    
    # Crear directorio de distribución
    $distDir = Join-Path $ProjectRoot "dist\windows"
    if (!(Test-Path $distDir)) {
        New-Item -ItemType Directory -Path $distDir -Force | Out-Null
        Write-Host "Directorio 'dist\windows' creado" -ForegroundColor Green
    }
    
    # Copiar archivos ejecutables
    $sourceDir = Join-Path $ProjectRoot "build\windows\x64\runner\Release"
    Write-Host "Buscando archivos en: $sourceDir" -ForegroundColor Cyan
    
    if (!(Test-Path $sourceDir)) {
        Write-Host "Error: Directorio de build no encontrado: $sourceDir" -ForegroundColor Red
        Write-Host "Verificando estructura de directorios..." -ForegroundColor Yellow
        
        # Verificar si existe el directorio build
        $buildDir = Join-Path $ProjectRoot "build"
        if (!(Test-Path $buildDir)) {
            Write-Host "Error: No existe el directorio 'build'. El build fallo." -ForegroundColor Red
        } else {
            Write-Host "Directorio 'build' existe. Contenido:" -ForegroundColor Yellow
            Get-ChildItem $buildDir -Recurse -Directory | Select-Object FullName
        }
        exit 1
    }
    
    Write-Host "Copiando archivos desde: $sourceDir" -ForegroundColor Yellow
    Copy-Item -Path "$sourceDir\*" -Destination $distDir -Recurse -Force
    
    # Crear archivo ZIP
    $zipPath = Join-Path $ProjectRoot "dist\${APP_NAME}_v${Version}_windows.zip"
    Write-Host "Creando archivo ZIP..." -ForegroundColor Yellow
    
    try {
        Compress-Archive -Path "$distDir\*" -DestinationPath $zipPath -Force
        Write-Host "Build de Windows completado: $zipPath" -ForegroundColor Green
        
        # Mostrar información del archivo
        $fileInfo = Get-Item $zipPath
        $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        Write-Host "Tamaño del archivo: $sizeMB MB" -ForegroundColor Cyan
        
    } catch {
        Write-Host "Error al crear archivo ZIP: $_" -ForegroundColor Red
        exit 1
    }
}

# Ejecutar builds según la plataforma especificada
switch ($Platform.ToLower()) {
    "windows" {
        Build-Windows
    }
    "macos" {
        Write-Host "Build de macOS no disponible en Windows" -ForegroundColor Cyan
        Write-Host "Para build de macOS, usar macOS o script build_release.sh" -ForegroundColor Cyan
    }
    "linux" {
        Write-Host "Build de Linux no disponible en Windows" -ForegroundColor Cyan
        Write-Host "Para build de Linux, usar Linux o WSL con script build_release.sh" -ForegroundColor Cyan
    }
    "all" {
        Build-Windows
        Write-Host ""
        Write-Host "Nota: Solo se puede hacer build de Windows en este sistema" -ForegroundColor Cyan
        Write-Host "Para builds multiplataforma, usar los scripts específicos de cada OS" -ForegroundColor Cyan
    }
    default {
        Write-Host "Plataforma no soportada: $Platform" -ForegroundColor Red
        Write-Host "Plataformas disponibles: windows, macos, linux, all" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Build completado exitosamente!" -ForegroundColor Green
Write-Host "Archivos generados en el directorio 'dist\'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "1. Probar los ejecutables generados" -ForegroundColor White
Write-Host "2. Crear un release en GitHub con estos archivos" -ForegroundColor White
Write-Host "3. Actualizar la URL de releases en update_service.dart" -ForegroundColor White
Write-Host ""

# Mostrar información del archivo generado
$zipFile = Join-Path $ProjectRoot "dist\${APP_NAME}_v${Version}_windows.zip"
if (Test-Path $zipFile) {
    $fileInfo = Get-Item $zipFile
    Write-Host "Archivo generado:" -ForegroundColor Cyan
    Write-Host "   Nombre: $($fileInfo.Name)" -ForegroundColor White
    $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "   Tamaño: $sizeMB MB" -ForegroundColor White
    Write-Host "   Ubicacion: $($fileInfo.FullName)" -ForegroundColor White
} else {
    Write-Host "Advertencia: No se encontro el archivo ZIP generado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
Read-Host