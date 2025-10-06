#!/bin/bash

# Script automatizado para crear y publicar actualizaciones
# Uso: ./release_update.sh [version] [descripción]

set -e

VERSION=${1:-"1.0.1"}
DESCRIPTION=${2:-"Nueva actualización disponible"}
APP_NAME="men_barberia"
REPO="juancecian/MenBarberiaApp"

echo "🚀 Iniciando proceso de actualización v$VERSION"
echo "📝 Descripción: $DESCRIPTION"

# Verificar que estemos en la rama main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Error: Debes estar en la rama 'main' para crear un release"
    exit 1
fi

# Verificar que no hay cambios sin commit
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Error: Hay cambios sin commit. Commit primero:"
    git status --short
    exit 1
fi

echo "✅ Verificaciones iniciales completadas"

# 1. Actualizar versión en pubspec.yaml
echo "📝 Actualizando versión en pubspec.yaml..."
sed -i.bak "s/version: .*/version: $VERSION+$(date +%s)/" pubspec.yaml
rm pubspec.yaml.bak

# 2. Actualizar versión en update_service.dart
echo "📝 Actualizando versión en update_service.dart..."
sed -i.bak "s/return '.*'; \/\/ Actualizar con cada nueva versión/return '$VERSION'; \/\/ Actualizar con cada nueva versión/" lib/services/update_service.dart
rm lib/services/update_service.dart.bak

# 3. Generar builds
echo "🔨 Generando builds de release..."
./scripts/build_release.sh $VERSION

# 4. Actualizar app-archive.json
echo "📄 Actualizando app-archive.json..."
cat > app-archive.json << EOF
{
  "appName": "Men Barbería",
  "description": "Aplicación de gestión para barbería",
  "items": [
    {
      "version": "$VERSION",
      "shortVersion": $(date +%s | tail -c 2),
      "changes": [
        {
          "type": "feat",
          "message": "$DESCRIPTION"
        },
        {
          "type": "chore",
          "message": "Mejoras de rendimiento y estabilidad"
        }
      ],
      "date": "$(date +%Y-%m-%d)",
      "mandatory": false,
      "url": "https://github.com/$REPO/releases/download/v$VERSION/${APP_NAME}_v${VERSION}_windows.zip",
      "platform": "windows"
    },
    {
      "version": "$VERSION",
      "shortVersion": $(date +%s | tail -c 2),
      "changes": [
        {
          "type": "feat",
          "message": "$DESCRIPTION"
        },
        {
          "type": "chore",
          "message": "Mejoras de rendimiento y estabilidad"
        }
      ],
      "date": "$(date +%Y-%m-%d)",
      "mandatory": false,
      "url": "https://github.com/$REPO/releases/download/v$VERSION/${APP_NAME}_v${VERSION}_macos.dmg",
      "platform": "macos"
    },
    {
      "version": "$VERSION",
      "shortVersion": $(date +%s | tail -c 2),
      "changes": [
        {
          "type": "feat",
          "message": "$DESCRIPTION"
        },
        {
          "type": "chore",
          "message": "Mejoras de rendimiento y estabilidad"
        }
      ],
      "date": "$(date +%Y-%m-%d)",
      "mandatory": false,
      "url": "https://github.com/$REPO/releases/download/v$VERSION/${APP_NAME}_v${VERSION}_linux.tar.gz",
      "platform": "linux"
    }
  ]
}
EOF

# 5. Commit cambios
echo "💾 Commiteando cambios..."
git add pubspec.yaml lib/services/update_service.dart app-archive.json
git commit -m "feat: release v$VERSION - $DESCRIPTION"

# 6. Crear tag
echo "🏷️  Creando tag v$VERSION..."
git tag -a "v$VERSION" -m "Release v$VERSION: $DESCRIPTION"

# 7. Push cambios y tag
echo "⬆️  Subiendo cambios a GitHub..."
git push origin main
git push origin "v$VERSION"

echo ""
echo "🎉 ¡Proceso completado exitosamente!"
echo ""
echo "📋 Próximos pasos manuales:"
echo "1. Ir a: https://github.com/$REPO/releases"
echo "2. Encontrar el tag 'v$VERSION' y crear release"
echo "3. Subir los archivos de dist/:"
ls -la dist/ | grep "$VERSION" | awk '{print "   - " $9}'
echo "4. Publicar el release"
echo ""
echo "🔗 URLs importantes:"
echo "- Release: https://github.com/$REPO/releases/tag/v$VERSION"
echo "- Archive: https://raw.githubusercontent.com/$REPO/main/app-archive.json"
echo ""
echo "⏱️  Las apps instaladas verificarán actualizaciones automáticamente"
echo "    en las próximas 24 horas o al reiniciar la aplicación."
