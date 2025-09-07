# Configuración de Entorno de Desarrollo - Proyecto-Z

Esta guía te ayudará a configurar tu entorno de desarrollo para contribuir al proyecto.

## 📋 **Tabla de Contenidos**

- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación de Herramientas](#instalación-de-herramientas)
- [Configuración del Proyecto](#configuración-del-proyecto)
- [Verificación de la Instalación](#verificación-de-la-instalación)
- [Configuración de Git](#configuración-de-git)
- [Configuración del Editor](#configuración-del-editor)
- [Troubleshooting](#troubleshooting)

## 🖥️ **Requisitos del Sistema**

### **Sistemas Operativos Soportados**
- **Windows 10/11** (64-bit)
- **macOS 10.15+** (Intel/Apple Silicon)
- **Linux** (Ubuntu 20.04+, Arch Linux, etc.)

### **Especificaciones Mínimas**
- **RAM**: 4GB (8GB recomendado)
- **Almacenamiento**: 2GB libres
- **Procesador**: 64-bit
- **Resolución**: 1280x720 (1920x1080 recomendado)

## 🛠️ **Instalación de Herramientas**

### **1. Godot Engine 4.4+**

#### **Windows**
```bash
# Opción 1: Descarga directa
# 1. Ir a https://godotengine.org/download
# 2. Descargar Godot 4.4+ (Standard)
# 3. Extraer y agregar al PATH

# Opción 2: Chocolatey
choco install godot

# Opción 3: Scoop
scoop install godot
```

#### **macOS**
```bash
# Opción 1: Homebrew
brew install --cask godot

# Opción 2: Descarga directa
# 1. Ir a https://godotengine.org/download
# 2. Descargar Godot 4.4+ (Standard)
# 3. Mover a /Applications
```

#### **Linux**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install godot4

# Arch Linux
sudo pacman -S godot

# Fedora
sudo dnf install godot

# Snap
sudo snap install godot --classic
```

### **2. Git**

#### **Windows**
```bash
# Descargar desde https://git-scm.com/download/win
# O usar Chocolatey:
choco install git

# O usar Scoop:
scoop install git
```

#### **macOS**
```bash
# Homebrew
brew install git

# Xcode Command Line Tools
xcode-select --install
```

#### **Linux**
```bash
# Ubuntu/Debian
sudo apt install git

# Arch Linux
sudo pacman -S git

# Fedora
sudo dnf install git
```

### **3. Editor de Código (Opcional pero Recomendado)**

#### **Visual Studio Code**
```bash
# Windows (Chocolatey)
choco install vscode

# macOS (Homebrew)
brew install --cask visual-studio-code

# Linux
# Descargar desde https://code.visualstudio.com/
```

#### **Extensiones Recomendadas para VS Code**
- **GDScript** (por Godot)
- **Godot Tools** (por Godot)
- **GitLens** (por Eric Amodio)
- **Git Graph** (por mhutchie)
- **Bracket Pair Colorizer** (por CoenraadS)

## 🎮 **Configuración del Proyecto**

### **1. Clonar el Repositorio**

```bash
# Clonar tu fork
git clone https://github.com/TU_USUARIO/mystic-dungeon-crawler.git
cd mystic-dungeon-crawler

# Agregar upstream remote
git remote add upstream https://github.com/ORIGINAL_USUARIO/mystic-dungeon-crawler.git

# Verificar remotes
git remote -v
```

### **2. Configurar Scripts de Desarrollo**

```bash
# Hacer scripts ejecutables
chmod +x tools/scripts/*.sh

# Verificar que funcionan
./tools/scripts/check_syntax.sh
./tools/scripts/clean_project.sh
```

### **3. Abrir en Godot**

```bash
# Abrir proyecto en Godot
godot project.godot

# O usar script de desarrollo
./tools/scripts/dev.sh
```

## ✅ **Verificación de la Instalación**

### **1. Verificar Godot**

```bash
# Verificar versión
godot --version
# Debería mostrar: 4.4.x

# Verificar que puede abrir el proyecto
godot --headless --check-only --path .
# Debería mostrar: ✅ Sin errores
```

### **2. Verificar Git**

```bash
# Verificar versión
git --version
# Debería mostrar: git version 2.x.x

# Verificar configuración
git config --global user.name
git config --global user.email
```

### **3. Verificar Proyecto**

```bash
# Verificar sintaxis
./tools/scripts/check_syntax.sh
# Debería mostrar: ✅ Verificación completada exitosamente

# Verificar build
./tools/scripts/build.sh
# Debería generar build exitosamente
```

## 🔧 **Configuración de Git**

### **1. Configuración Básica**

```bash
# Configurar usuario
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@ejemplo.com"

# Configurar editor
git config --global core.editor "code --wait"  # Para VS Code
# o
git config --global core.editor "nano"  # Para nano
```

### **2. Configuración Avanzada**

```bash
# Configurar merge tool
git config --global merge.tool vscode

# Configurar diff tool
git config --global diff.tool vscode

# Configurar alias útiles
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### **3. Configuración de SSH (Opcional)**

```bash
# Generar clave SSH
ssh-keygen -t ed25519 -C "tu-email@ejemplo.com"

# Agregar clave a ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copiar clave pública
cat ~/.ssh/id_ed25519.pub
# Pegar en GitHub > Settings > SSH and GPG keys
```

## 💻 **Configuración del Editor**

### **VS Code - Configuración Recomendada**

Crear archivo `.vscode/settings.json`:

```json
{
    "files.associations": {
        "*.gd": "gdscript"
    },
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.rulers": [80, 120],
    "editor.wordWrap": "wordWrapColumn",
    "editor.wordWrapColumn": 80,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "godot_tools.editor_path": "/path/to/godot",
    "godot_tools.gdscript_lsp_server_port": 6005,
    "godot_tools.gdscript_lsp_server_host": "127.0.0.1"
}
```

### **VS Code - Extensiones Recomendadas**

Crear archivo `.vscode/extensions.json`:

```json
{
    "recommendations": [
        "godot.godot-tools",
        "eamodio.gitlens",
        "mhutchie.git-graph",
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "ms-vscode.powershell"
    ]
}
```

## 🐛 **Troubleshooting**

### **Problemas Comunes**

#### **"Godot not found"**
```bash
# Solución 1: Agregar al PATH
export PATH="/path/to/godot:$PATH"

# Solución 2: Crear symlink
sudo ln -s /path/to/godot /usr/local/bin/godot

# Solución 3: Usar ruta completa en scripts
# Editar tools/scripts/*.sh y cambiar 'godot' por '/path/to/godot'
```

#### **"Permission denied" en scripts**
```bash
# Solución: Hacer ejecutables
chmod +x tools/scripts/*.sh

# Verificar permisos
ls -la tools/scripts/
```

#### **"Git repository not found"**
```bash
# Solución: Inicializar Git
git init
git remote add origin https://github.com/TU_USUARIO/mystic-dungeon-crawler.git
```

#### **"Build failed"**
```bash
# Solución 1: Verificar export presets
# 1. Abrir Godot
# 2. Ir a Project > Export
# 3. Configurar presets necesarios

# Solución 2: Limpiar proyecto
./tools/scripts/clean_project.sh
./tools/scripts/build.sh
```

#### **"Syntax errors"**
```bash
# Solución 1: Verificar sintaxis
./tools/scripts/check_syntax.sh

# Solución 2: Abrir en Godot para ver errores detallados
godot project.godot
```

### **Logs y Debug**

```bash
# Ver logs detallados de Godot
godot --verbose --path .

# Ver logs de build
./tools/scripts/build.sh -v

# Ver estado de Git
./tools/scripts/sync.sh --status
```

## 🚀 **Primeros Pasos**

### **1. Verificar Instalación Completa**

```bash
# Ejecutar script de verificación
./tools/scripts/check_syntax.sh
./tools/scripts/build.sh
./tools/scripts/sync.sh --status
```

### **2. Iniciar Desarrollo**

```bash
# Iniciar entorno de desarrollo
./tools/scripts/dev.sh

# En otra terminal, hacer cambios y verificar
./tools/scripts/check_syntax.sh
```

### **3. Hacer Primer Commit**

```bash
# Crear rama para feature
git checkout -b feature/mi-primera-contribucion

# Hacer cambios
# ... editar archivos ...

# Verificar cambios
./tools/scripts/check_syntax.sh

# Commit
git add .
git commit -m "feat: añadir mi primera contribución"

# Push
git push origin feature/mi-primera-contribucion
```

## 📚 **Recursos Adicionales**

### **Documentación**
- **[Getting Started](getting-started.md)**
- **[Contributing Guide](../contributing/CONTRIBUTING.md)**
- **[Architecture Docs](../docs/architecture/)**

### **Enlaces Útiles**
- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Git Documentation](https://git-scm.com/doc)
- [VS Code Documentation](https://code.visualstudio.com/docs)

### **Comunidad**
- [Godot Community](https://godotengine.org/community)
- [GitHub Discussions](https://github.com/TU_USUARIO/mystic-dungeon-crawler/discussions)
- [Discord Server](https://discord.gg/godot) (si tienes uno)

## 🤝 **Obtener Ayuda**

Si tienes problemas con la configuración:

1. **Revisar** esta guía y troubleshooting
2. **Buscar** en GitHub Issues
3. **Crear** nuevo issue con detalles del problema
4. **Preguntar** en GitHub Discussions
5. **Contactar** a los maintainers

---

*Última actualización: Diciembre 2024*
*Versión: 1.0.0*
