#!/bin/bash
# Script de limpieza del proyecto Godot
# Elimina archivos de caché e importación para solucionar problemas

echo "🧹 Iniciando limpieza del proyecto..."

# Eliminar archivos .import
echo "Eliminando archivos .import..."
find . -name "*.import" -delete

# Eliminar caché de Godot si existe
if [ -d ".godot" ]; then
    echo "Eliminando caché .godot..."
    rm -rf .godot
fi

# Eliminar archivos temporales
echo "Eliminando archivos temporales..."
find . -name "*.tmp" -delete

echo "✅ Limpieza completada!"
echo "Puedes abrir el proyecto en Godot ahora."
