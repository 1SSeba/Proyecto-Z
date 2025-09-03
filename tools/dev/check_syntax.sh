#!/bin/bash
# Script para verificar sintaxis básica de archivos GDScript

echo "=== VERIFICACIÓN DE SINTAXIS ==="

# Verificar archivos principales
files=(
    "Autoload/DebugManager.gd"
    "Scenes/MainMenu/SettingsMenu.gd"
    "Core/StateMachine/StateMachine.gd"
    "Core/Events/EventBus.gd"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file - Existe"
        # Verificar que no tenga caracteres problemáticos
        if grep -q $'\t' "$file"; then
            echo "⚠️  $file - Contiene tabs (puede ser problemático)"
        fi
        # Verificar sintaxis básica de señales
        if grep -n "signal.*for\|signal.*in\|signal.*:" "$file"; then
            echo "❌ $file - Sintaxis de señal problemática"
        fi
    else
        echo "❌ $file - No existe"
    fi
done

echo "=== VERIFICACIÓN COMPLETADA ==="
