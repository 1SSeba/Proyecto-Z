# ⚙️ Capa de Servicios y ServiceManager

## 📋 **Índice**
- [Visión General](#visión-general)
- [ServiceManager](#servicemanager)
- [Servicios Disponibles](#servicios-disponibles)
- [Ciclo de Vida de Servicios](#ciclo-de-vida-de-servicios)
- [Crear Nuevos Servicios](#crear-nuevos-servicios)
- [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 **Visión General**

La **capa de servicios** proporciona funcionalidades centralizadas y reutilizables para todo el proyecto. Los servicios son singletons que manejan aspectos específicos del juego como configuración, audio, input, etc.

### **Ubicación y Configuración**
ServiceManager.get_audio_service()
        "context": current_context
func load_config() -> void
<!-- service-layer.md
    ServiceManager and services summary for Proyecto-Z
-->


# Service Layer — ServiceManager (Proyecto-Z)

Autoload: `ServiceManager` — `res://game/core/ServiceManager.gd`

> Nota
>
> El `ServiceManager` actúa como orquestador de servicios globales. Los servicios suelen instanciarse y añadirse como hijos del `ServiceManager` para centralizar ciclo de vida y acceso.

## API (resumen)

- `ServiceManager.get_config_service()`
- `ServiceManager.get_audio_service()`
- `ServiceManager.get_input_service()`
- `ServiceManager.is_service_ready(name: String) -> bool`

## Servicios comunes (convenciones)

- `ConfigService` — persistencia y valores por defecto (`res://game/core/services/ConfigService.gd`).
- `AudioService` — reproducción y pools de SFX (`res://game/core/services/AudioService.gd`).
- `InputService` — buffering y contextos de entrada (`res://game/core/services/InputService.gd`).

<details>
<summary>Ejemplo: inicialización típica (expandir)</summary>

```gdscript
# En ServiceManager._ready() o initialize()
_config_service = ConfigService.new()
add_child(_config_service)
_config_service.initialize()

_input_service = InputService.new()
add_child(_input_service)
_input_service.initialize()

_audio_service = AudioService.new()
add_child(_audio_service)
_audio_service.initialize()
```

</details>

## Crear un servicio

1. Heredar de `GameService` o `Node` y exponer una API pública.
2. Implementar `initialize()` y `cleanup()` (o `start_service`/`stop_service`).
3. Registrar/crear en `ServiceManager` (p. ej. en `_create_service()`).

> Buenas prácticas
>
> - Mantener servicios stateless cuando sea posible.
> - Comprobar disponibilidad con `is_service_ready` antes de usar un servicio.
> - Emitir eventos vía `EventBus` para cambios observables (config, audio, etc.).

## Verificación rápida

- [ ] Confirmar rutas de servicios bajo `res://game/core/services/`.
- [ ] Alinear nombres de clases en `ServiceManager` y los archivos físicos.

Última actualización: 2025-09-06
