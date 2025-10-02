#!/bin/bash

# Men Barbería - Script de Build para macOS
# Este script construye la aplicación para distribución en macOS

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

echo "🍎 Iniciando build para macOS..."

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
flutter build macos --release

# Verificar que el build fue exitoso
if [ -e "build/macos/Build/Products/Release/men_barberia.app" ]; then
    echo "✅ Build completado exitosamente!"
    echo "📍 Aplicación disponible en: build/macos/Build/Products/Release/men_barberia.app"
    
    # Mostrar información del archivo
    echo "📊 Información del build:"
    ls -lah "build/macos/Build/Products/Release/men_barberia.app"
    
    # Opciones post-build
    echo ""
    echo "🎯 ¿Qué deseas hacer ahora?"
    echo "1) Instalar en este Mac"
    echo "2) Crear DMG para distribución"
    echo "3) Solo mostrar ubicación"
    echo ""
    read -p "Selecciona una opción (1-3): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            echo "🚀 Instalando en este Mac..."
            ./scripts/install_macos.sh
            ;;
        2)
            echo "📦 Creando DMG para distribución..."
            ./scripts/create_simple_dmg.sh
            ;;
        3)
            echo "📍 La aplicación está lista en: build/macos/Build/Products/Release/men_barberia.app"
            echo "💡 Para instalar manualmente: cp -R 'build/macos/Build/Products/Release/men_barberia.app' '/Applications/'"
            ;;
        *)
            echo "📍 La aplicación está lista en: build/macos/Build/Products/Release/men_barberia.app"
            ;;
    esac
    
else
    echo "❌ Error: Build falló"
    exit 1
fi

echo "🎉 Proceso completado!"
