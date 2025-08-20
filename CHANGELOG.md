# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Agregado
- Sistema de debug con consola integrada
- Sistema de managers modulares (GameManager, InputManager, etc.)
- Sistema de configuración persistente
- Menú principal completo con opciones
- Sistema de jugador con movimiento y animaciones

### En Desarrollo
- Sistema de combate
- Enemigos y AI
- Generación procedural de niveles
- Sistema de inventario

## [0.1.0] - 2025-08-20

### Agregado
- Configuración inicial del proyecto en Godot 4.4
- Estructura base de carpetas y autoloads
- Sistema de jugador básico con movimiento
- Menú principal con navegación
- Sistema de configuración de audio y video
- Console de debug con comandos
- Arquitectura modular con managers
- Animaciones básicas del jugador (idle, run, attack)
- Sistema de salud y daño del jugador
- Gestión de estados del juego

### Configurado
- Autoloads para gestión global del juego
- Estructura de proyecto escalable
- Sistema de input centralizado
- Gestión de audio básica
- Sistema de debug integrado

### Técnico
- Godot 4.4 como engine base
- Resolución base 960x540 con escalado
- Soporte para múltiples resoluciones
- Filtrado de texturas pixelado
- Sistema de señales para comunicación entre componentes

---

## Convenciones del Changelog

### Tipos de cambios
- `Agregado` para nuevas funcionalidades
- `Cambiado` para cambios en funcionalidades existentes
- `Deprecado` para funcionalidades que serán removidas
- `Removido` para funcionalidades removidas
- `Corregido` para bug fixes
- `Seguridad` para vulnerabilidades
