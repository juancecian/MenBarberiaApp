#!/bin/bash

# Men Barbería - Creador de DMG con Instalador Visual
# Este script crea un archivo DMG profesional para distribución

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

APP_NAME="men_barberia.app"
APP_PATH="build/macos/Build/Products/Release/$APP_NAME"
DMG_NAME="Men_Barberia_Installer"
DMG_PATH="build/${DMG_NAME}.dmg"
TEMP_DMG_PATH="build/${DMG_NAME}_temp.dmg"
MOUNT_POINT="build/dmg_mount"

echo "📦 Creando DMG Instalador para Men Barbería"
echo "==========================================="

# Verificar que la app existe
if [ ! -e "$APP_PATH" ]; then
    echo "❌ Error: No se encontró la aplicación en $APP_PATH"
    echo "💡 Ejecuta primero: ./build_macos.sh"
    exit 1
fi

# Limpiar archivos anteriores
echo "🧹 Limpiando archivos anteriores..."
rm -rf "$MOUNT_POINT"
rm -f "$DMG_PATH"
rm -f "$TEMP_DMG_PATH"

# Crear directorio temporal para el DMG
echo "📁 Preparando contenido del DMG..."
mkdir -p "$MOUNT_POINT"

# Copiar la aplicación
cp -R "$APP_PATH" "$MOUNT_POINT/"

# Crear enlace simbólico a Applications
ln -s /Applications "$MOUNT_POINT/Applications"

# Crear archivo de información
cat > "$MOUNT_POINT/LEEME.txt" << EOF
Men Barbería - Aplicación de Gestión para Barbería
===============================================

INSTALACIÓN:
1. Arrastra "men_barberia.app" a la carpeta "Applications"
2. La aplicación estará disponible en Launchpad
3. Al abrir por primera vez, macOS puede pedir confirmación de seguridad

REQUISITOS:
• macOS 10.14 o superior
• 100 MB de espacio libre

SOPORTE:
• Para soporte técnico, contacta al desarrollador
• Versión: 1.0.0

© 2025 Men Barbería Solutions
EOF

# Crear DMG temporal más grande para personalización
echo "🔨 Creando archivo DMG temporal..."
hdiutil create -srcfolder "$MOUNT_POINT" -volname "Men Barbería Installer" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 300m "$TEMP_DMG_PATH"

# Montar DMG para personalización
echo "🎨 Personalizando DMG..."
MOUNT_DIR="/Volumes/Men Barbería Installer"
hdiutil attach "$TEMP_DMG_PATH" -noautoopen -quiet -mountpoint "$MOUNT_DIR"

# Esperar a que se monte correctamente
sleep 2

# Crear directorio oculto para recursos
mkdir -p "$MOUNT_DIR/.background"

# Configurar vista del Finder con AppleScript mejorado
if command -v osascript &> /dev/null; then
    echo "🎨 Configurando interfaz visual del DMG..."
    osascript << EOF
tell application "Finder"
    tell disk "Men Barbería Installer"
        open
        
        -- Configurar ventana
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 640, 480}
        
        -- Configurar vista de iconos
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set text size of theViewOptions to 13
        
        -- Posicionar elementos
        set position of item "men_barberia.app" of container window to {160, 220}
        set position of item "Applications" of container window to {480, 220}
        set position of item "LEEME.txt" of container window to {320, 350}
        
        -- Configurar ventana final
        set the bounds of container window to {100, 100, 640, 480}
        
        -- Actualizar y cerrar
        update without registering applications
        delay 2
        close
    end tell
end tell
EOF
    
    echo "✅ Interfaz visual configurada"
else
    echo "⚠️  AppleScript no disponible, usando configuración básica"
fi

# Crear archivo .DS_Store personalizado para mantener la configuración
echo "📝 Creando configuración persistente..."

# Desmontar DMG temporal
echo "🔄 Desmontando DMG temporal..."
hdiutil detach "$MOUNT_DIR" -quiet || hdiutil detach "$MOUNT_DIR" -force -quiet

# Convertir a DMG final comprimido
echo "📦 Comprimiendo DMG final..."
hdiutil convert "$TEMP_DMG_PATH" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"

# Limpiar archivos temporales
rm -f "$TEMP_DMG_PATH"
rm -rf "$MOUNT_POINT"

# Verificar resultado
if [ -e "$DMG_PATH" ]; then
    echo "✅ ¡DMG creado exitosamente!"
    echo "📍 Ubicación: $DMG_PATH"
    echo "📊 Tamaño: $(du -h "$DMG_PATH" | cut -f1)"
    echo ""
    echo "🎉 El instalador está listo para distribución:"
    echo "   • Los usuarios pueden abrir el DMG"
    echo "   • Arrastrar la app a Applications"
    echo "   • El DMG se puede distribuir por email, web, etc."
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
