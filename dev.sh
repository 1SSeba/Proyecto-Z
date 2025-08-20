#!/bin/bash
# dev.sh - Script de desarrollo esencial

case "$1" in
    "run")
        echo "🏃 Running game..."
        godot project.godot
        ;;
    "check")
        echo "📊 Checking for errors..."
        godot --headless --check-only 2>&1 | head -20
        ;;
    "export")
        echo "🚀 Quick export..."
        ./tools/quick_export.sh
        ;;
    "clean")
        echo "🧹 Cleaning builds..."
        rm -rf builds/debug/*
        echo "✅ Cleaned"
        ;;
    *)
        echo "🔧 Development Commands:"
        echo "  ./dev.sh run      - Run game in editor"
        echo "  ./dev.sh check    - Check for errors"
        echo "  ./dev.sh export   - Quick export"
        echo "  ./dev.sh clean    - Clean builds"
        ;;
esac
