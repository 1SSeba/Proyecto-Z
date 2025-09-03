# Controles y Atajos de Teclado

## 🎮 Problema Solucionado: ESC ya no cierra el juego

### ❌ **Antes**: 
- Presionar ESC en cualquier momento cerraba el juego inmediatamente

### ✅ **Ahora**:
- ESC tiene comportamiento contextual más inteligente
- Solo cierra submenús, no el juego completo

## 🎯 **Controles por Contexto**

### **En el Menú Principal:**
- **ENTER**: Iniciar juego
- **ESC**: Cerrar menú de configuraciones (si está abierto)
- **Ctrl + S**: Abrir configuraciones
- **Ctrl + Q**: Salir del juego (Linux estándar)
- **Alt + F4**: Salir del juego (Windows estándar)

### **En el Menú de Configuraciones:**
- **ESC**: Volver al menú principal
- **Tab**: Navegar entre opciones
- **Enter**: Aplicar cambios
- **Ctrl + S**: Guardar configuraciones

### **Durante el Juego:**
- **ESC**: Pausar/Reanudar juego
- **WASD**: Movimiento
- **Espacio**: Acción principal
- **X**: Acción secundaria
- **Tab**: Inventario
- **M**: Menú
- **F3**: Toggle debug

### **En Pausa:**
- **ESC**: Reanudar juego
- **Q**: Volver al menú principal
- **R**: Reiniciar nivel

## 🔧 **Archivos Modificados**

### 1. `content/scenes/Menus/MainMenuModular.gd`
- Cambió el comportamiento de ESC para no cerrar el juego
- Agregó Ctrl+Q y Alt+F4 como métodos de salida
- Mejoró el manejo contextual de teclas

### 2. `src/systems/StateMachine/States/MainMenuState.gd`
- Removió la funcionalidad de ESC para cerrar el juego
- Agregó las mismas combinaciones de teclas de salida
- Mejoró la consistencia con el MainMenu

### 3. Comportamiento sin cambios (correcto):
- `GameStateManager.gd`: ESC sigue pausando/reanudando
- `GameplayState.gd`: ESC sigue pausando el juego
- `SettingsMenu.gd`: ESC sigue cerrando el menú

## 💡 **Beneficios de los Cambios**

✅ **Menos salidas accidentales**: ESC ya no cierra el juego por error  
✅ **Comportamiento estándar**: Ctrl+Q (Linux) y Alt+F4 (Windows)  
✅ **Navegación intuitiva**: ESC cierra menús, no el juego  
✅ **Experiencia consistente**: Comportamiento predictible en todos los contextos  
✅ **Mejor UX**: Usuarios no pierden progreso por presionar ESC  

## 🧪 **Testing Realizado**

- ✅ ESC en menú principal: Solo cierra submenús
- ✅ ESC durante el juego: Pausa/reanuda correctamente
- ✅ ESC en configuraciones: Vuelve al menú principal
- ✅ Ctrl+Q: Cierra el juego con cleanup
- ✅ Alt+F4: Cierra el juego con cleanup
- ✅ Botón Quit: Sigue funcionando normalmente

## 📝 **Notas para el Usuario**

- **Para salir rápido**: Usa `Ctrl+Q` en lugar de ESC
- **Para navegar**: ESC cierra menús y submenús
- **Para pausar**: ESC durante el juego pausa/reanuda
- **Configuraciones**: Se guardan automáticamente al cerrar menús

---

**🎯 El comportamiento de ESC ahora es mucho más intuitivo y seguro!**
