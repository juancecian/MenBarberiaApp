#!/bin/bash

# Men Barbería - Creador de DMG Instalador Profesional
# Este script crea un DMG con interfaz visual estándar de macOS

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

APP_NAME="men_barberia.app"
APP_PATH="build/macos/Build/Products/Release/$APP_NAME"
DMG_NAME="Men_Barberia_Installer"
DMG_PATH="build/${DMG_NAME}.dmg"
TEMP_DIR="build/dmg_temp"
VOLUME_NAME="Men Barbería"

echo "📦 Creando DMG Instalador Profesional para Men Barbería"
echo "======================================================"

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

# Crear enlace simbólico a Applications con nombre personalizado
ln -s /Applications "$TEMP_DIR/Instalar aquí"

# Crear archivo de instrucciones más visible
cat > "$TEMP_DIR/INSTRUCCIONES.txt" << EOF
INSTALACIÓN DE MEN BARBERÍA
==========================

Para instalar Men Barbería en tu Mac:

1. Arrastra el icono "men_barberia.app" 
   hacia la carpeta "Instalar aquí"

2. La aplicación se copiará a Applications

3. Busca "Men Barbería" en Launchpad
   o ábrela desde Applications

4. ¡Listo! Ya puedes usar Men Barbería

NOTA: Al abrir por primera vez, macOS puede 
pedir confirmación de seguridad. Esto es normal.

© 2025 Men Barbería Solutions
Versión 1.0.0
EOF

# Crear DMG usando create-dmg si está disponible, sino usar método manual
if command -v create-dmg &> /dev/null; then
    echo "🔨 Creando DMG con create-dmg..."
    create-dmg \
        --volname "$VOLUME_NAME" \
        --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 128 \
        --icon "$APP_NAME" 150 190 \
        --hide-extension "$APP_NAME" \
        --app-drop-link 450 190 \
        --text-size 13 \
        --background-color "#2C2C2E" \
        "$DMG_PATH" \
        "$TEMP_DIR"
else
    echo "🔨 Creando DMG manualmente..."
    
    # Crear DMG temporal
    hdiutil create -srcfolder "$TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ -format UDRW -size 250m "$DMG_PATH.temp"
    
    # Montar para personalización
    MOUNT_POINT="/Volumes/$VOLUME_NAME"
    hdiutil attach "$DMG_PATH.temp" -noautoopen -quiet -mountpoint "$MOUNT_POINT"
    
    # Esperar montaje
    sleep 3
    
    # Configurar con AppleScript
    osascript << EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        
        -- Configurar ventana
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        
        -- Configurar vista de iconos
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set text size of theViewOptions to 13
        
        -- Posicionar elementos para instalación visual
        set position of item "$APP_NAME" of container window to {150, 200}
        set position of item "Instalar aquí" of container window to {450, 200}
        set position of item "INSTRUCCIONES.txt" of container window to {300, 320}
        
        -- Configurar ventana final
        set the bounds of container window to {100, 100, 700, 500}
        
        -- Actualizar
        update without registering applications
        delay 3
        close
    end tell
end tell
EOF
    
    # Desmontar
    hdiutil detach "$MOUNT_POINT" -quiet
    
    # Convertir a formato final
    hdiutil convert "$DMG_PATH.temp" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"
    rm -f "$DMG_PATH.temp"
fi

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

# Verificar resultado
if [ -e "$DMG_PATH" ]; then
    echo "✅ ¡DMG Instalador creado exitosamente!"
    echo "📍 Ubicación: $DMG_PATH"
    echo "📊 Tamaño: $(du -h "$DMG_PATH" | cut -f1)"
    echo ""
    echo "🎉 El instalador profesional está listo:"
    echo "   • Al abrir el DMG, los usuarios verán:"
    echo "     - El icono de Men Barbería a la izquierda"
    echo "     - La carpeta 'Instalar aquí' a la derecha"
    echo "     - Instrucciones claras en la parte inferior"
    echo "   • Solo necesitan arrastrar la app a 'Instalar aquí'"
    echo "   • El DMG se puede distribuir fácilmente"
    echo ""
    
    # Preguntar si abrir el DMG
    read -p "¿Deseas abrir el DMG para verificar la interfaz? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$DMG_PATH"
    fi
else
    echo "❌ Error: La creación del DMG falló"
    exit 1
fi

echo "🎉 ¡Instalador profesional completado!"
