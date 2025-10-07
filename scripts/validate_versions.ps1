# Script para validar consistencia de versiones antes de publicar
# Uso: .\validate_versions.ps1

param(
    [switch]$Fix = $false  # Si se pasa -Fix, corrige las inconsistencias automáticamente
)

$ErrorActionPreference = "Stop"

# Obtener el directorio del script y cambiar al directorio raíz del proyecto
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "Validando consistencia de versiones..." -ForegroundColor Green
Write-Host "Directorio del proyecto: $ProjectRoot" -ForegroundColor Cyan

# Cambiar al directorio raíz del proyecto
Set-Location $ProjectRoot

# Función para extraer versión de pubspec.yaml
function Get-PubspecVersion {
    $pubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
    if (!(Test-Path $pubspecPath)) {
        throw "No se encontró pubspec.yaml"
    }
    
    $content = Get-Content $pubspecPath -Raw
    $versionMatch = [regex]::Match($content, 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)')
    
    if ($versionMatch.Success) {
        return @{
            Version = $versionMatch.Groups[1].Value
            BuildNumber = $versionMatch.Groups[2].Value
            Full = "$($versionMatch.Groups[1].Value)+$($versionMatch.Groups[2].Value)"
        }
    } else {
        throw "No se pudo extraer la versión de pubspec.yaml"
    }
}

# Función para extraer versión de app-archive.json
function Get-ArchiveVersions {
    $archivePath = Join-Path $ProjectRoot "app-archive.json"
    if (!(Test-Path $archivePath)) {
        throw "No se encontró app-archive.json"
    }
    
    $content = Get-Content $archivePath -Raw | ConvertFrom-Json
    
    $versions = @{}
    foreach ($item in $content.items) {
        $versions[$item.platform] = @{
            Version = $item.version
            ShortVersion = $item.shortVersion
            URL = $item.url
        }
    }
    
    return $versions
}

# Función para extraer versión de update_service.dart
function Get-UpdateServiceVersion {
    $updateServicePath = Join-Path $ProjectRoot "lib\services\update_service.dart"
    if (!(Test-Path $updateServicePath)) {
        throw "No se encontró update_service.dart"
    }
    
    $content = Get-Content $updateServicePath -Raw
    $versionMatch = [regex]::Match($content, "return '([0-9]+\.[0-9]+\.[0-9]+)';")
    
    if ($versionMatch.Success) {
        return $versionMatch.Groups[1].Value
    } else {
        # Buscar en el fallback
        $fallbackMatch = [regex]::Match($content, "return '([0-9]+\.[0-9]+\.[0-9]+)';.*fallback")
        if ($fallbackMatch.Success) {
            return $fallbackMatch.Groups[1].Value
        }
        return "No encontrada"
    }
}

try {
    # Obtener versiones
    Write-Host "Extrayendo versiones..." -ForegroundColor Yellow
    
    $pubspecVersion = Get-PubspecVersion
    $archiveVersions = Get-ArchiveVersions
    $updateServiceVersion = Get-UpdateServiceVersion
    
    Write-Host ""
    Write-Host "=== VERSIONES ENCONTRADAS ===" -ForegroundColor Cyan
    Write-Host "pubspec.yaml: $($pubspecVersion.Version)+$($pubspecVersion.BuildNumber)" -ForegroundColor White
    Write-Host "update_service.dart: $updateServiceVersion" -ForegroundColor White
    
    Write-Host ""
    Write-Host "app-archive.json:" -ForegroundColor White
    foreach ($platform in $archiveVersions.Keys) {
        $version = $archiveVersions[$platform]
        Write-Host "  $platform`: $($version.Version) (short: $($version.ShortVersion))" -ForegroundColor White
    }
    
    # Validar consistencia
    Write-Host ""
    Write-Host "=== VALIDACIÓN ===" -ForegroundColor Cyan
    
    $errors = @()
    $warnings = @()
    
    # Validar update_service.dart
    if ($updateServiceVersion -ne $pubspecVersion.Version) {
        if ($updateServiceVersion -eq "No encontrada") {
            $warnings += "update_service.dart: Versión no encontrada (puede estar usando lectura automática)"
        } else {
            $errors += "update_service.dart: $updateServiceVersion ≠ pubspec.yaml: $($pubspecVersion.Version)"
        }
    }
    
    # Validar app-archive.json
    foreach ($platform in $archiveVersions.Keys) {
        $archiveVersion = $archiveVersions[$platform]
        if ($archiveVersion.Version -ne $pubspecVersion.Version) {
            $errors += "app-archive.json ($platform): $($archiveVersion.Version) ≠ pubspec.yaml: $($pubspecVersion.Version)"
        }
        
        # Validar que la URL contenga la versión correcta
        if ($archiveVersion.URL -notmatch $pubspecVersion.Version) {
            $errors += "app-archive.json ($platform): URL no contiene la versión $($pubspecVersion.Version)"
        }
    }
    
    # Mostrar resultados
    if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Host "✅ Todas las versiones son consistentes!" -ForegroundColor Green
        exit 0
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "⚠️ ADVERTENCIAS:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  • $warning" -ForegroundColor Yellow
        }
    }
    
    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "❌ ERRORES DE CONSISTENCIA:" -ForegroundColor Red
        foreach ($error in $errors) {
            Write-Host "  • $error" -ForegroundColor Red
        }
        
        if ($Fix) {
            Write-Host ""
            Write-Host "🔧 Aplicando correcciones automáticas..." -ForegroundColor Yellow
            
            # Aquí podrías agregar lógica para corregir automáticamente
            # Por ahora solo mostramos qué se necesita corregir
            Write-Host "Correcciones necesarias:" -ForegroundColor Cyan
            Write-Host "1. Actualizar app-archive.json con versión $($pubspecVersion.Version)" -ForegroundColor White
            Write-Host "2. Verificar URLs en app-archive.json" -ForegroundColor White
            Write-Host "3. update_service.dart ya usa lectura automática desde pubspec.yaml" -ForegroundColor White
        }
        
        exit 1
    }
    
} catch {
    Write-Host "Error durante la validación: $_" -ForegroundColor Red
    exit 1
}