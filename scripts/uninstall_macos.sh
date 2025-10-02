#!/bin/bash

# Men Barbería - Desinstalador para macOS
# Este script desinstala completamente la aplicación del sistema

set -e

APP_NAME="men_barberia.app"
INSTALL_PATH="/Applications/$APP_NAME"
BACKUP_PATH="/Applications/${APP_NAME}.backup"
DATA_PATHS=(
    "$HOME/Library/Application Support/men_barberia"
    "$HOME/Library/Preferences/com.menbarberia.men-barberia.plist"
    "$HOME/Library/Logs/men_barberia"
    "$HOME/Library/Caches/men_barberia"
)

echo "🗑️  Desinstalador de Men Barbería para macOS"
echo "==========================================="

# Verificar si la app está instalada
if [ ! -e "$INSTALL_PATH" ]; then
    echo "⚠️  Men Barbería no está instalada en $INSTALL_PATH"
    
    # Verificar backup
    if [ -e "$BACKUP_PATH" ]; then
        echo "📦 Se encontró un backup en $BACKUP_PATH"
        read -p "¿Deseas eliminar el backup también? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$BACKUP_PATH"
            echo "✅ Backup eliminado"
        fi
    fi
else
    echo "📍 Men Barbería encontrada en: $INSTALL_PATH"
    echo ""
    echo "⚠️  ADVERTENCIA: Esta acción eliminará:"
    echo "   • La aplicación Men Barbería"
    echo "   • Todos los datos de usuario"
    echo "   • Configuraciones y preferencias"
    echo "   • Logs y archivos de caché"
    echo ""
    
    read -p "¿Estás seguro de que deseas desinstalar Men Barbería? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Desinstalación cancelada"
        exit 0
    fi
    
    # Cerrar la aplicación si está ejecutándose
    echo "🔄 Cerrando Men Barbería si está ejecutándose..."
    pkill -f "men_barberia" 2>/dev/null || true
    sleep 2
    
    # Eliminar la aplicación principal
    echo "🗑️  Eliminando aplicación..."
    rm -rf "$INSTALL_PATH"
    
    # Eliminar backup si existe
    if [ -e "$BACKUP_PATH" ]; then
        echo "🗑️  Eliminando backup..."
        rm -rf "$BACKUP_PATH"
    fi
    
    # Eliminar datos de usuario
    echo "🗑️  Eliminando datos de usuario..."
    for data_path in "${DATA_PATHS[@]}"; do
        if [ -e "$data_path" ]; then
            echo "   • Eliminando: $data_path"
            rm -rf "$data_path"
        fi
    done
    
    # Limpiar Launchpad (forzar actualización)
    echo "🔄 Actualizando Launchpad..."
    defaults write com.apple.dock ResetLaunchPad -bool true
    killall Dock 2>/dev/null || true
    
    echo ""
    echo "✅ ¡Men Barbería ha sido desinstalada completamente!"
    echo ""
    echo "📋 Elementos eliminados:"
    echo "   • Aplicación principal"
    echo "   • Datos de usuario y configuraciones"
    echo "   • Logs y archivos temporales"
    echo "   • Entradas de Launchpad"
    echo ""
    echo "🔄 El Dock se reiniciará para actualizar Launchpad"
fi

echo "🎉 Proceso de desinstalación completado"
