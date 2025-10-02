#!/bin/bash

# Men Barbería - Script de Configuración para Producción
# Este script configura los identificadores y certificados necesarios

echo "🔧 Configurando aplicación para producción..."

# Función para actualizar Bundle ID en macOS
update_macos_bundle_id() {
    local bundle_id=$1
    echo "📱 Actualizando Bundle ID para macOS: $bundle_id"
    
    # Actualizar en project.pbxproj
    if [ -f "macos/Runner.xcodeproj/project.pbxproj" ]; then
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $bundle_id;/g" macos/Runner.xcodeproj/project.pbxproj
        echo "✅ Bundle ID actualizado en project.pbxproj"
    fi
}

# Función para configurar firma de código
setup_code_signing() {
    echo "🔐 Configurando firma de código para macOS..."
    echo "📋 Pasos manuales requeridos:"
    echo "   1. Abre Xcode"
    echo "   2. Ve a macos/Runner.xcworkspace"
    echo "   3. Selecciona el proyecto Runner"
    echo "   4. En 'Signing & Capabilities':"
    echo "      - Habilita 'Automatically manage signing'"
    echo "      - Selecciona tu Team"
    echo "      - Verifica el Bundle Identifier"
    echo "   5. Configura las capabilities necesarias:"
    echo "      - Network (Client/Server)"
    echo "      - File Access (User Selected Files)"
    echo ""
}

# Solicitar Bundle ID
read -p "📝 Ingresa tu Bundle ID (ej: com.tuempresa.menbarberia): " bundle_id

if [ ! -z "$bundle_id" ]; then
    update_macos_bundle_id "$bundle_id"
    setup_code_signing
    
    echo "✅ Configuración completada!"
    echo "📋 Próximos pasos:"
    echo "   1. Configura la firma de código en Xcode (ver instrucciones arriba)"
    echo "   2. Para Windows: No requiere certificados para distribución básica"
    echo "   3. Ejecuta ./scripts/build_macos.sh para macOS"
    echo "   4. Ejecuta ./scripts/build_windows.sh para Windows"
else
    echo "❌ Bundle ID requerido"
    exit 1
fi
