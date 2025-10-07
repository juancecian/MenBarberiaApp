# Script para actualizar versiones de forma consistente
# Uso: .\update_version.ps1 [version] [build_number]
# Ejemplo: .\update_version.ps1 1.0.2 3

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$BuildNumber = "1",
    
    [switch]$DryRun = $false  # Solo mostrar qué se haría, sin hacer cambios
)

$ErrorActionPreference = "Stop"

# Obtener el directorio del script y cambiar al directorio raíz del proyecto
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "Actualizando versiones a $Version+$BuildNumber" -ForegroundColor Green
Write-Host "Directorio del proyecto: $ProjectRoot" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 MODO DRY-RUN: Solo mostrando cambios, sin aplicar" -ForegroundColor Yellow
}

# Cambiar al directorio raíz del proyecto
Set-Location $ProjectRoot

# Validar formato de versión
if (!($Version -match '^[0-9]+\.[0-9]+\.[0-9]+$')) {
    Write-Host "Error: La versión debe tener formato X.Y.Z (ej: 1.0.2)" -ForegroundColor Red
    exit 1
}

if (!($BuildNumber -match '^[0-9]+$')) {
    Write-Host "Error: El build number debe ser un número entero" -ForegroundColor Red
    exit 1
}

try {
    # 1. Actualizar pubspec.yaml
    Write-Host ""
    Write-Host "=== ACTUALIZANDO pubspec.yaml ===" -ForegroundColor Cyan
    $pubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
    
    if (!(Test-Path $pubspecPath)) {
        throw "No se encontró pubspec.yaml"
    }
    
    $pubspecContent = Get-Content $pubspecPath -Raw
    $newPubspecContent = $pubspecContent -replace 'version:\s*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+', "version: $Version+$BuildNumber"
    
    if ($DryRun) {
        Write-Host "Se cambiaría: version: $Version+$BuildNumber" -ForegroundColor Yellow
    } else {
        Set-Content $pubspecPath $newPubspecContent -Encoding UTF8
        Write-Host "✅ pubspec.yaml actualizado" -ForegroundColor Green
    }
    
    # 2. Actualizar app-archive.json
    Write-Host ""
    Write-Host "=== ACTUALIZANDO app-archive.json ===" -ForegroundColor Cyan
    $archivePath = Join-Path $ProjectRoot "app-archive.json"
    
    if (!(Test-Path $archivePath)) {
        throw "No se encontró app-archive.json"
    }
    
    $archiveContent = Get-Content $archivePath -Raw | ConvertFrom-Json
    $updated = $false
    
    foreach ($item in $archiveContent.items) {
        $oldVersion = $item.version
        $oldShortVersion = $item.shortVersion
        $oldURL = $item.url
        
        # Actualizar versión
        $item.version = $Version
        $item.shortVersion = [int]$BuildNumber
        
        # Actualizar URL
        $newURL = $oldURL -replace '/v[0-9]+\.[0-9]+\.[0-9]+/', "/v$Version/"
        $newURL = $newURL -replace '_v[0-9]+\.[0-9]+\.[0-9]+_', "_v${Version}_"
        $item.url = $newURL
        
        # Actualizar fecha
        $item.date = Get-Date -Format "yyyy-MM-dd"
        
        if ($DryRun) {
            Write-Host "Plataforma $($item.platform):" -ForegroundColor Yellow
            Write-Host "  Versión: $oldVersion → $Version" -ForegroundColor Yellow
            Write-Host "  ShortVersion: $oldShortVersion → $BuildNumber" -ForegroundColor Yellow
            Write-Host "  URL: $oldURL" -ForegroundColor Yellow
            Write-Host "       → $newURL" -ForegroundColor Yellow
            Write-Host "  Fecha: → $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor Yellow
        } else {
            $updated = $true
        }
    }
    
    if (!$DryRun -and $updated) {
        $archiveContent | ConvertTo-Json -Depth 10 | Set-Content $archivePath -Encoding UTF8
        Write-Host "✅ app-archive.json actualizado" -ForegroundColor Green
    }
    
    # 3. Verificar update_service.dart
    Write-Host ""
    Write-Host "=== VERIFICANDO update_service.dart ===" -ForegroundColor Cyan
    $updateServicePath = Join-Path $ProjectRoot "lib\services\update_service.dart"
    
    if (Test-Path $updateServicePath) {
        $updateServiceContent = Get-Content $updateServicePath -Raw
        
        # Verificar si usa lectura automática
        if ($updateServiceContent -match "getCurrentVersion\(\)") {
            if ($updateServiceContent -match "pubspecFile\.readAsStringSync\(\)") {
                Write-Host "✅ update_service.dart ya usa lectura automática desde pubspec.yaml" -ForegroundColor Green
            } else {
                Write-Host "⚠️ update_service.dart tiene versión hardcodeada" -ForegroundColor Yellow
                Write-Host "  Considera actualizar para usar lectura automática" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "⚠️ No se encontró update_service.dart" -ForegroundColor Yellow
    }
    
    # 4. Validar consistencia
    Write-Host ""
    Write-Host "=== VALIDANDO CONSISTENCIA ===" -ForegroundColor Cyan
    
    if (!$DryRun) {
        # Ejecutar script de validación
        $validateScript = Join-Path $ScriptDir "validate_versions.ps1"
        if (Test-Path $validateScript) {
            & $validateScript
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Todas las versiones son consistentes" -ForegroundColor Green
            } else {
                Write-Host "❌ Se encontraron inconsistencias" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Ejecutaría validación de consistencia..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
    Write-Host "Versión objetivo: $Version+$BuildNumber" -ForegroundColor White
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "Para aplicar estos cambios, ejecuta:" -ForegroundColor Yellow
        Write-Host ".\scripts\update_version.ps1 $Version $BuildNumber" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "Próximos pasos:" -ForegroundColor Yellow
        Write-Host "1. Probar la aplicación localmente" -ForegroundColor White
        Write-Host "2. Ejecutar builds de release" -ForegroundColor White
        Write-Host "3. Crear release en GitHub" -ForegroundColor White
        Write-Host "4. Subir app-archive.json actualizado" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error durante la actualización: $_" -ForegroundColor Red
    exit 1
}
