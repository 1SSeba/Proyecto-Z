#!/bin/bash
# Script para limpiar y reimportar assets de Godot

echo "🧹 Limpiando caché de Godot..."

# Eliminar carpeta .godot completamente
if [ -d ".godot" ]; then
    rm -rf .godot
    echo "✅ Eliminada carpeta .godot"
fi

# Recrear carpeta .godot con permisos correctos
mkdir -p .godot
chmod 755 .godot
echo "✅ Recreada carpeta .godot"

# Asegurar permisos de escritura en todo el proyecto
chmod -R u+w .
echo "✅ Permisos de escritura configurados"

# Eliminar archivos temporales
find . -name "*.tmp" -delete 2>/dev/null
find . -name "*~" -delete 2>/dev/null
echo "✅ Archivos temporales eliminados"

# Verificar archivos de importación
echo "🔍 Verificando archivos .import..."
import_count=$(find Assets/ -name "*.import" | wc -l)
echo "   Encontrados $import_count archivos .import"

echo ""
echo "🎮 Pasos siguientes:"
echo "1. Abre el proyecto en Godot"
echo "2. Godot reimportará automáticamente todos los assets"
echo "3. Los errores de MD5 deberían desaparecer"
echo ""
echo "⚠️  IMPORTANTE: Permite que Godot complete la importación antes de ejecutar el juego"
