# Script para verificar la versión del ejecutable compilado
param()

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

$exePath = "build\windows\x64\runner\Release\MenBarberia.exe"

if (!(Test-Path $exePath)) {
    Write-Host "Error: No se encontró el ejecutable en $exePath" -ForegroundColor Red
    Write-Host "Ejecuta 'flutter build windows --release' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "Verificando versión del ejecutable..." -ForegroundColor Green
Write-Host "Archivo: $exePath" -ForegroundColor Cyan

try {
    # Obtener información del archivo
    $fileInfo = Get-Item $exePath
    $versionInfo = $fileInfo.VersionInfo
    
    Write-Host ""
    Write-Host "=== INFORMACIÓN DE VERSIÓN ===" -ForegroundColor Cyan
    Write-Host "Product Version: $($versionInfo.ProductVersion)" -ForegroundColor White
    Write-Host "File Version: $($versionInfo.FileVersion)" -ForegroundColor White
    Write-Host "Product Name: $($versionInfo.ProductName)" -ForegroundColor White
    
    # Verificar si la versión coincide con pubspec.yaml
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    $pubspecMatch = [regex]::Match($pubspecContent, 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)')
    $pubspecVersion = $pubspecMatch.Groups[1].Value
    
    Write-Host ""
    Write-Host "=== COMPARACIÓN ===" -ForegroundColor Cyan
    Write-Host "pubspec.yaml: $pubspecVersion" -ForegroundColor White
    Write-Host "Ejecutable: $($versionInfo.ProductVersion)" -ForegroundColor White
    
    if ($versionInfo.ProductVersion -eq $pubspecVersion) {
        Write-Host ""
        Write-Host "✅ Las versiones coinciden!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Las versiones NO coinciden" -ForegroundColor Red
        Write-Host "   Esto puede causar problemas en las actualizaciones" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error al verificar la versión: $_" -ForegroundColor Red
}
