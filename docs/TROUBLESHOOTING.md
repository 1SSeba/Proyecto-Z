# Guía de Solución de Problemas - Referencia Rápida 🚨

## 🔧 Herramientas de solución automática

### Script de limpieza completa
```bash
./tools/clean_cache.sh
```
**Uso**: Resuelve problemas de caché, permisos y assets corruptos.

## ⚡ Soluciones rápidas

### 🚫 Error: "Cannot open MD5 file" / "Unable to open .ctex"
```bash
./tools/clean_cache.sh
# Luego abrir Godot y esperar reimportación
```

### 🚫 Error: "Could not find type StateMachine/State"
1. Verificar que existe `Core/StateMachine/StateMachine.gd`
2. Verificar que existe `Core/StateMachine/State.gd`
3. Cerrar y reabrir Godot

### 🚫 Error: "Parse Error: Class already exists"
```bash
# Buscar archivos duplicados
find . -name "*.gd" -exec basename {} \; | sort | uniq -c | sort -nr
```

### 🚫 Error: "Permission denied"
```bash
chmod -R u+w .
```

## 📂 Estructura esperada (sin errores)

```
topdown-game/
├── Core/
│   ├── StateMachine/
│   │   ├── StateMachine.gd      ✅ class_name StateMachine
│   │   ├── State.gd             ✅ class_name State  
│   │   └── States/              ✅ Todos heredan de State
│   └── Events/
│       ├── EventBus.gd          ✅ Autoload configurado
│       └── GameEvent.gd         ✅ class_name GameEvent
├── Autoload/                    ✅ Todos en project.godot
└── docs/                        ✅ Documentación completa
```

## 🎯 Checklist de verificación

### Antes de ejecutar el juego:
- [ ] Script de limpieza ejecutado
- [ ] Godot abierto y assets reimportados
- [ ] No hay errores en la consola de Godot
- [ ] Todos los scripts compilan correctamente

### Si hay errores persistentes:
- [ ] Verificar `project.godot` para autoloads correctos
- [ ] Revisar que no hay archivos `.gd` duplicados
- [ ] Comprobar permisos de escritura
- [ ] Reiniciar Godot completamente

## 📞 Soporte adicional

- **Diagnóstico completo**: Ver `docs/ERRORS_DIAGNOSTIC.md`
- **Estructura del proyecto**: Ver `docs/PROJECT_STRUCTURE.md`  
- **Estado del sistema**: Ver `docs/PROJECT_STATUS.md`

---

**💡 Consejo**: Si un problema no se resuelve con estas soluciones, probablemente es un problema específico del entorno. Revisar la documentación completa en `docs/`.
