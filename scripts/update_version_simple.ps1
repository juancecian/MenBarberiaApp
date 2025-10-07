# Script simple para actualizar versiones
param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$BuildNumber = "1",
    
    [switch]$DryRun = $false
)

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

Write-Host "Actualizando versiones a $Version+$BuildNumber" -ForegroundColor Green

if ($DryRun) {
    Write-Host "MODO DRY-RUN: Solo mostrando cambios" -ForegroundColor Yellow
}

# Validar formato
if (!($Version -match '^[0-9]+\.[0-9]+\.[0-9]+$')) {
    Write-Host "Error: La version debe tener formato X.Y.Z" -ForegroundColor Red
    exit 1
}

try {
    # 1. Actualizar pubspec.yaml
    Write-Host ""
    Write-Host "=== ACTUALIZANDO pubspec.yaml ===" -ForegroundColor Cyan
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    $newPubspecContent = $pubspecContent -replace 'version:\s*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+', "version: $Version+$BuildNumber"
    
    if ($DryRun) {
        Write-Host "Se cambiaria: version: $Version+$BuildNumber" -ForegroundColor Yellow
    } else {
        Set-Content "pubspec.yaml" $newPubspecContent -Encoding UTF8
        Write-Host "pubspec.yaml actualizado" -ForegroundColor Green
    }
    
    # 2. Actualizar app-archive.json
    Write-Host ""
    Write-Host "=== ACTUALIZANDO app-archive.json ===" -ForegroundColor Cyan
    $archiveContent = Get-Content "app-archive.json" -Raw | ConvertFrom-Json
    
    foreach ($item in $archiveContent.items) {
        $oldVersion = $item.version
        $oldURL = $item.url
        
        $item.version = $Version
        $item.shortVersion = [int]$BuildNumber
        $item.date = Get-Date -Format "yyyy-MM-dd"
        
        # Actualizar URL
        $newURL = $oldURL -replace '/v[0-9]+\.[0-9]+\.[0-9]+/', "/v$Version/"
        $newURL = $newURL -replace '_v[0-9]+\.[0-9]+\.[0-9]+_', "_v${Version}_"
        $item.url = $newURL
        
        if ($DryRun) {
            Write-Host "Plataforma $($item.platform):" -ForegroundColor Yellow
            Write-Host "  Version: $oldVersion -> $Version" -ForegroundColor Yellow
            Write-Host "  URL: $oldURL" -ForegroundColor Yellow
            Write-Host "       -> $newURL" -ForegroundColor Yellow
        }
    }
    
    if (!$DryRun) {
        $archiveContent | ConvertTo-Json -Depth 10 | Set-Content "app-archive.json" -Encoding UTF8
        Write-Host "app-archive.json actualizado" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
    Write-Host "Version objetivo: $Version+$BuildNumber" -ForegroundColor White
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "Para aplicar cambios:" -ForegroundColor Yellow
        Write-Host ".\scripts\update_version_simple.ps1 $Version $BuildNumber" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "Proximos pasos:" -ForegroundColor Yellow
        Write-Host "1. Probar la aplicacion" -ForegroundColor White
        Write-Host "2. Ejecutar builds de release" -ForegroundColor White
        Write-Host "3. Crear release en GitHub" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
