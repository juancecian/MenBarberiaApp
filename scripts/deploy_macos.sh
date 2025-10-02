#!/bin/bash

# Men Barbería - Script de Despliegue Completo para macOS
# Este script maneja todo el proceso desde build hasta instalación/distribución

set -e

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

echo "🚀 Men Barbería - Despliegue Completo para macOS"
echo "==============================================="
echo ""

# Verificar dependencias
check_dependencies() {
    echo "🔍 Verificando dependencias..."
    
    # Verificar Flutter
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter no está instalado"
        exit 1
    fi
    
    # Verificar CocoaPods
    if ! command -v pod &> /dev/null; then
        echo "⚠️  CocoaPods no está instalado"
        echo "💡 Instalando CocoaPods..."
        sudo gem install cocoapods
        pod setup
    fi
    
    echo "✅ Dependencias verificadas"
}

# Mostrar menú principal
show_menu() {
    echo ""
    echo "🎯 ¿Qué deseas hacer?"
    echo "1) Build completo + Instalar en este Mac"
    echo "2) Build completo + Crear DMG para distribución"
    echo "3) Solo hacer build"
    echo "4) Solo instalar (si ya tienes el build)"
    echo "5) Solo crear DMG (si ya tienes el build)"
    echo "6) Desinstalar Men Barbería"
    echo "7) Salir"
    echo ""
    read -p "Selecciona una opción (1-7): " -n 1 -r
    echo
    return $REPLY
}

# Ejecutar build
run_build() {
    echo "🔨 Ejecutando build para macOS..."
    ./scripts/build_macos.sh
}

# Ejecutar instalación
run_install() {
    echo "📱 Ejecutando instalación..."
    ./scripts/install_macos.sh
}

# Crear DMG
create_dmg() {
    echo "📦 Creando DMG..."
    ./scripts/create_simple_dmg.sh
}

# Desinstalar
run_uninstall() {
    echo "🗑️  Ejecutando desinstalación..."
    ./scripts/uninstall_macos.sh
}

# Función principal
main() {
    check_dependencies
    
    while true; do
        show_menu
        option=$?
        
        case $option in
            1)
                echo "🚀 Opción 1: Build + Instalación"
                run_build
                echo ""
                run_install
                break
                ;;
            2)
                echo "📦 Opción 2: Build + DMG"
                run_build
                echo ""
                create_dmg
                break
                ;;
            3)
                echo "🔨 Opción 3: Solo Build"
                run_build
                break
                ;;
            4)
                echo "📱 Opción 4: Solo Instalación"
                run_install
                break
                ;;
            5)
                echo "📦 Opción 5: Solo DMG"
                create_dmg
                break
                ;;
            6)
                echo "🗑️  Opción 6: Desinstalación"
                run_uninstall
                break
                ;;
            7)
                echo "👋 ¡Hasta luego!"
                exit 0
                ;;
            *)
                echo "❌ Opción inválida. Intenta de nuevo."
                ;;
        esac
    done
    
    echo ""
    echo "🎉 ¡Proceso completado exitosamente!"
    echo ""
    echo "📋 Scripts disponibles:"
    echo "   • ./build_macos.sh     - Solo build"
    echo "   • ./install_macos.sh   - Solo instalación"
    echo "   • ./create_dmg.sh      - Solo DMG"
    echo "   • ./uninstall_macos.sh - Desinstalación"
    echo "   • ./deploy_macos.sh    - Este script (completo)"
}

# Ejecutar función principal
main
