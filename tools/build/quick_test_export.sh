#!/bin/bash
# Quick Export Script para probar el juego fuera del editor

echo "🎮 Quick Export Script"
echo "======================"

# Configurar directorios
GAME_DIR="/home/scruzd/Desktop/topdown-game"
BUILD_DIR="$GAME_DIR/builds/debug"
EXPORT_NAME="game_debug"

# Ir al directorio del juego
cd "$GAME_DIR" || exit 1

# Crear directorio de build si no existe
mkdir -p "$BUILD_DIR"

echo "📁 Directorio de build: $BUILD_DIR"
echo "🎯 Exportando juego para pruebas..."

# Exportar usando Godot headless
godot --headless --export-debug "Linux/X11" "$BUILD_DIR/$EXPORT_NAME" --verbose

# Verificar si la exportación fue exitosa
if [ -f "$BUILD_DIR/$EXPORT_NAME" ]; then
    echo "✅ Exportación exitosa!"
    echo "📍 Archivo generado: $BUILD_DIR/$EXPORT_NAME"
    
    # Hacer ejecutable
    chmod +x "$BUILD_DIR/$EXPORT_NAME"
    
    echo ""
    echo "🚀 Para ejecutar el juego:"
    echo "   cd $BUILD_DIR"
    echo "   ./$EXPORT_NAME"
    echo ""
    echo "🎮 ¿Quieres ejecutar el juego ahora? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🎮 Ejecutando juego..."
        cd "$BUILD_DIR"
        "./$EXPORT_NAME"
    fi
else
    echo "❌ Error en la exportación"
    echo "💡 Verifica que:"
    echo "   - Godot esté instalado y en el PATH"
    echo "   - El preset de exportación 'Linux/X11' esté configurado"
    echo "   - No haya errores en el proyecto"
fi

echo ""
echo "📝 Notas:"
echo "   - Las configuraciones de video funcionarán correctamente fuera del editor"
echo "   - Los buses de audio se crearán automáticamente"
echo "   - Las configuraciones se guardarán en ~/.local/share/godot/app_userdata/Topdown Roguelike/"
