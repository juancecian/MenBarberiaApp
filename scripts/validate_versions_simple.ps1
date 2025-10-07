# Script simple para validar versiones
param()

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

Write-Host "Validando versiones..." -ForegroundColor Green

try {
    # Leer pubspec.yaml
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    $pubspecMatch = [regex]::Match($pubspecContent, 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)')
    $pubspecVersion = $pubspecMatch.Groups[1].Value
    $pubspecBuild = $pubspecMatch.Groups[2].Value

    # Leer app-archive.json
    $archiveContent = Get-Content "app-archive.json" -Raw | ConvertFrom-Json
    $archiveVersions = @{}
    foreach ($item in $archiveContent.items) {
        $archiveVersions[$item.platform] = $item.version
    }

    # Leer update_service.dart
    $updateContent = Get-Content "lib\services\update_service.dart" -Raw
    $updateMatch = [regex]::Match($updateContent, "return '([0-9]+\.[0-9]+\.[0-9]+)';")
    $updateVersion = if ($updateMatch.Success) { $updateMatch.Groups[1].Value } else { "No encontrada" }

    Write-Host ""
    Write-Host "VERSIONES ENCONTRADAS:" -ForegroundColor Cyan
    Write-Host "pubspec.yaml: $pubspecVersion+$pubspecBuild" -ForegroundColor White
    Write-Host "update_service.dart: $updateVersion" -ForegroundColor White
    Write-Host "app-archive.json:" -ForegroundColor White
    foreach ($platform in $archiveVersions.Keys) {
        Write-Host "  $platform`: $($archiveVersions[$platform])" -ForegroundColor White
    }

    # Validar
    $errors = @()
    
    if ($updateVersion -ne $pubspecVersion -and $updateVersion -ne "No encontrada") {
        $errors += "update_service.dart ($updateVersion) ≠ pubspec.yaml ($pubspecVersion)"
    }
    
    foreach ($platform in $archiveVersions.Keys) {
        if ($archiveVersions[$platform] -ne $pubspecVersion) {
            $errors += "app-archive.json $platform ($($archiveVersions[$platform])) ≠ pubspec.yaml ($pubspecVersion)"
        }
    }

    if ($errors.Count -eq 0) {
        Write-Host ""
        Write-Host "✅ Todas las versiones son consistentes!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ ERRORES:" -ForegroundColor Red
        foreach ($error in $errors) {
            Write-Host "  • $error" -ForegroundColor Red
        }
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
