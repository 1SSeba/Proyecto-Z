# Event System — EventBus (Proyecto-Z)

> Nota
>
> `EventBus` es el hub global de señales para Proyecto-Z. Use este documento para registrar nuevas señales y patrones de uso.
```gdscript
<!-- event-system.md
   Minimal EventBus doc for Proyecto-Z
-->

# Event System — EventBus (Proyecto-Z)

Autoload: `EventBus` — res://game/core/events/EventBus.gd

Descripción
- EventBus es el hub de señales global del proyecto. Emite y reenvía eventos que el juego y los componentes consumen.

Señales importantes (ejemplos)
- `entity_spawned(entity)`
- `entity_moved(entity, position)`
- `health_changed(entity, new_health)`
- `entity_died(entity)`
- `menu_opened(menu_name)`
- `menu_button_pressed(button_name)`
- `service_initialized(service_name)`


## Patrones de uso

<details>
<summary>Emisión de eventos</summary>

```gdscript
EventBus.health_changed.emit(entity, 75)
```

</details>

<details>
<summary>Suscripción y manejo</summary>

```gdscript
EventBus.health_changed.connect(_on_health_changed)

func _on_health_changed(entity, hp):
    if entity == self:
        update_ui(hp)
```

</details>

## Buenas prácticas

- Evitar lógica pesada en handlers síncronos; delegar a systems o corutinas.
- Usar nombres de señales descriptivos y documentarlos en este archivo.
- Desconectar señales en `_exit_tree()` cuando no se usen `CONNECT_ONESHOT`.

> Debug
>
> Si existe, utilice `EventBus.debug_print_connections()` para inspeccionar conexiones durante el desarrollo.

## Verificación rápida

- [ ] Documentar nuevas señales añadidas a `game/core/events/EventBus.gd`.
- [ ] Confirmar que los handlers desconectan correctamente en `_exit_tree()`.

*Última actualización: 2025-09-06*
