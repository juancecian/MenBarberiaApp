#!/bin/bash

# Script para crear releases de la aplicación Men Barbería
# Uso: ./build_release.sh [version] [platform]

set -e

VERSION=${1:-"1.0.0"}
PLATFORM=${2:-"all"}
APP_NAME="men_barberia"

echo "🚀 Iniciando build de release v$VERSION para $PLATFORM"

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean
flutter pub get

# Función para build de Windows
build_windows() {
    echo "🪟 Building para Windows..."
    flutter build windows --release
    
    # Crear directorio de distribución
    mkdir -p dist/windows
    
    # Copiar archivos ejecutables
    cp -r build/windows/x64/runner/Release/* dist/windows/
    
    # Crear archivo ZIP
    cd dist/windows
    zip -r "../${APP_NAME}_v${VERSION}_windows.zip" .
    cd ../..
    
    echo "✅ Build de Windows completado: dist/${APP_NAME}_v${VERSION}_windows.zip"
}

# Función para build de macOS
build_macos() {
    echo "🍎 Building para macOS..."
    flutter build macos --release
    
    # Crear directorio de distribución
    mkdir -p dist/macos
    
    # Copiar app bundle
    cp -r build/macos/Build/Products/Release/men_barberia.app dist/macos/
    
    # Crear archivo DMG (requiere create-dmg instalado)
    if command -v create-dmg &> /dev/null; then
        create-dmg \
            --volname "Men Barbería" \
            --window-pos 200 120 \
            --window-size 600 300 \
            --icon-size 100 \
            --icon "men_barberia.app" 175 120 \
            --hide-extension "men_barberia.app" \
            --app-drop-link 425 120 \
            "dist/${APP_NAME}_v${VERSION}_macos.dmg" \
            "dist/macos/"
    else
        # Crear ZIP si no está disponible create-dmg
        cd dist/macos
        zip -r "../${APP_NAME}_v${VERSION}_macos.zip" .
        cd ../..
    fi
    
    echo "✅ Build de macOS completado"
}

# Función para build de Linux
build_linux() {
    echo "🐧 Building para Linux..."
    flutter build linux --release
    
    # Crear directorio de distribución
    mkdir -p dist/linux
    
    # Copiar archivos ejecutables
    cp -r build/linux/x64/release/bundle/* dist/linux/
    
    # Crear archivo TAR.GZ
    cd dist/linux
    tar -czf "../${APP_NAME}_v${VERSION}_linux.tar.gz" .
    cd ../..
    
    echo "✅ Build de Linux completado: dist/${APP_NAME}_v${VERSION}_linux.tar.gz"
}

# Crear directorio dist si no existe
mkdir -p dist

# Ejecutar builds según la plataforma especificada
case $PLATFORM in
    "windows")
        build_windows
        ;;
    "macos")
        build_macos
        ;;
    "linux")
        build_linux
        ;;
    "all")
        if [[ "$OSTYPE" == "darwin"* ]]; then
            build_macos
        fi
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            build_linux
        fi
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            build_windows
        fi
        ;;
    *)
        echo "❌ Plataforma no soportada: $PLATFORM"
        echo "Plataformas disponibles: windows, macos, linux, all"
        exit 1
        ;;
esac

echo ""
echo "🎉 Build completado exitosamente!"
echo "📁 Archivos generados en el directorio 'dist/'"
echo ""
echo "📋 Próximos pasos:"
echo "1. Probar los ejecutables generados"
echo "2. Crear un release en GitHub con estos archivos"
echo "3. Actualizar la URL de releases en update_service.dart"
echo ""
