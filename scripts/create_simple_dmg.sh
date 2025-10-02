#!/bin/bash

# Men Barbería - Creador de DMG Simple y Funcional
# Este script crea un DMG con la interfaz estándar de arrastrar a Applications

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

APP_NAME="men_barberia.app"
APP_PATH="build/macos/Build/Products/Release/$APP_NAME"
DMG_NAME="Men_Barberia_Installer"
DMG_PATH="build/${DMG_NAME}.dmg"
TEMP_DIR="build/dmg_simple"
VOLUME_NAME="Men Barbería"

echo "📦 Creando DMG Instalador Simple para Men Barbería"
echo "================================================="

# Verificar que la app existe
if [ ! -e "$APP_PATH" ]; then
    echo "❌ Error: No se encontró la aplicación en $APP_PATH"
    echo "💡 Ejecuta primero: ./build_macos.sh"
    exit 1
fi

# Limpiar archivos anteriores
echo "🧹 Limpiando archivos anteriores..."
rm -rf "$TEMP_DIR"
rm -f "$DMG_PATH"

# Crear directorio temporal
echo "📁 Preparando contenido del instalador..."
mkdir -p "$TEMP_DIR"

# Copiar la aplicación
cp -R "$APP_PATH" "$TEMP_DIR/"

# Crear enlace simbólico a Applications
ln -s /Applications "$TEMP_DIR/Applications"

# Crear archivo README simple
cat > "$TEMP_DIR/README.txt" << EOF
Men Barbería - Instalación
=========================

Para instalar:
1. Arrastra "men_barberia.app" a la carpeta "Applications"
2. Busca la app en Launchpad o Applications

Versión: 1.0.0
© 2025 Men Barbería Solutions
EOF

# Crear DMG
echo "🔨 Creando DMG..."
hdiutil create -srcfolder "$TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ -format UDZO -imagekey zlib-level=9 "$DMG_PATH"

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

# Verificar resultado
if [ -e "$DMG_PATH" ]; then
    echo "✅ ¡DMG creado exitosamente!"
    echo "📍 Ubicación: $DMG_PATH"
    echo "📊 Tamaño: $(du -h "$DMG_PATH" | cut -f1)"
    echo ""
    echo "🎉 El instalador está listo:"
    echo "   • Al abrir el DMG, los usuarios verán la app y Applications"
    echo "   • Solo necesitan arrastrar men_barberia.app a Applications"
    echo "   • Es la interfaz estándar que esperan los usuarios de Mac"
    echo ""
    
    # Preguntar si abrir el DMG
    read -p "¿Deseas abrir el DMG para verificarlo? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$DMG_PATH"
    fi
else
    echo "❌ Error: La creación del DMG falló"
    exit 1
fi

echo "🎉 ¡DMG instalador completado!"
