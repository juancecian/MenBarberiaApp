#!/bin/bash

# Men Barbería - Instalador Automático para macOS
# Este script instala la aplicación en el sistema

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

APP_NAME="men_barberia.app"
APP_PATH="build/macos/Build/Products/Release/$APP_NAME"
INSTALL_PATH="/Applications/$APP_NAME"
BACKUP_PATH="/Applications/${APP_NAME}.backup"

echo "🍎 Instalador de Men Barbería para macOS"
echo "========================================"

# Verificar que la app existe
if [ ! -e "$APP_PATH" ]; then
    echo "❌ Error: No se encontró la aplicación en $APP_PATH"
    echo "💡 Ejecuta primero: ./build_macos.sh"
    exit 1
fi

# Verificar permisos de administrador
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Ejecutándose como root. Esto es innecesario para instalar en /Applications"
fi

# Verificar si la app ya está instalada
if [ -e "$INSTALL_PATH" ]; then
    echo "⚠️  Men Barbería ya está instalada en $INSTALL_PATH"
    read -p "¿Deseas reemplazar la instalación existente? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Creando backup de la versión actual..."
        if [ -e "$BACKUP_PATH" ]; then
            rm -rf "$BACKUP_PATH"
        fi
        mv "$INSTALL_PATH" "$BACKUP_PATH"
        echo "✅ Backup creado en: $BACKUP_PATH"
    else
        echo "❌ Instalación cancelada"
        exit 0
    fi
fi

# Instalar la aplicación
echo "🚀 Instalando Men Barbería..."
cp -R "$APP_PATH" "$INSTALL_PATH"

# Verificar instalación
if [ -e "$INSTALL_PATH" ]; then
    echo "✅ ¡Men Barbería instalada exitosamente!"
    echo "📍 Ubicación: $INSTALL_PATH"
    echo ""
    echo "🎉 La aplicación está lista para usar:"
    echo "   • Búscala en Launchpad"
    echo "   • O ábrela desde Applications"
    echo "   • O ejecuta: open '$INSTALL_PATH'"
    echo ""
    
    # Preguntar si abrir la aplicación
    read -p "¿Deseas abrir Men Barbería ahora? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Abriendo Men Barbería..."
        open "$INSTALL_PATH"
    fi
    
    # Información adicional
    echo ""
    echo "📋 Información adicional:"
    echo "   • Para desinstalar: rm -rf '$INSTALL_PATH'"
    echo "   • Backup disponible en: $BACKUP_PATH (si existía)"
    echo "   • Logs de la app: ~/Library/Logs/men_barberia/"
    
else
    echo "❌ Error: La instalación falló"
    exit 1
fi
