#!/bin/bash

# Men Barbería - Script de Build para Windows
# Este script construye la aplicación para distribución en Windows

set -e

echo "🪟 Iniciando build para Windows..."

# Verificar que estamos en un entorno que puede compilar para Windows
if ! flutter doctor | grep -q "Windows"; then
    echo "⚠️  Advertencia: Es posible que necesites estar en Windows o tener configurado el toolchain de Windows"
fi

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean
rm -rf build/

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar iconos
echo "🎨 Generando iconos..."
flutter pub run flutter_launcher_icons:main

# Build para Release
echo "🔨 Construyendo aplicación para Release..."
flutter build windows --release

# Verificar que el build fue exitoso
if [ -d "build/windows/x64/runner/Release" ]; then
    echo "✅ Build completado exitosamente!"
    echo "📍 Aplicación disponible en: build/windows/x64/runner/Release/"
    
    # Mostrar información del archivo
    echo "📊 Información del build:"
    ls -lah "build/windows/x64/runner/Release/"
    
    # Crear paquete ZIP para distribución
    echo "📦 Creando paquete ZIP para distribución..."
    cd build/windows/x64/runner/Release/
    zip -r "../../../../../Men_Barberia_Windows_v1.0.0.zip" ./*
    cd ../../../../../
    
    echo "✅ Paquete ZIP creado: Men_Barberia_Windows_v1.0.0.zip"
    
else
    echo "❌ Error: Build falló"
    exit 1
fi

echo "🎉 Proceso completado!"
echo "📋 Para distribuir en Windows:"
echo "   1. Descomprime el archivo ZIP en el equipo destino"
echo "   2. Ejecuta men_barberia.exe"
echo "   3. Asegúrate de que Visual C++ Redistributable esté instalado"
