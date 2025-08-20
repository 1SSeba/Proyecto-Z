#!/bin/bash
# quick_export.sh - Script para exportación rápida durante desarrollo

echo "🚀 Starting Quick Export for Development Testing..."

# Crear directorios si no existen
mkdir -p builds/debug
mkdir -p builds/debug/logs

# Obtener timestamp
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOG_FILE="builds/debug/logs/export_$TIMESTAMP.log"

echo "📁 Output directory: builds/debug/"
echo "📝 Log file: $LOG_FILE"

# Exportar con logs detallados
echo "⚙️ Running Godot export..."
godot --headless --export-debug "Linux/X11" "builds/debug/game_debug" 2>&1 | tee "$LOG_FILE"

# Verificar si la exportación fue exitosa
if [ $? -eq 0 ] && [ -f "builds/debug/game_debug" ]; then
    echo "✅ Export successful!"
    echo "🎮 Executable: builds/debug/game_debug"
    echo ""
    echo "💡 To test video settings:"
    echo "   cd builds/debug && ./game_debug"
    echo ""
    echo "🔍 Quick launch? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "🚀 Launching game..."
        cd builds/debug && ./game_debug
    fi
else
    echo "❌ Export failed! Check log file: $LOG_FILE"
    exit 1
fi
