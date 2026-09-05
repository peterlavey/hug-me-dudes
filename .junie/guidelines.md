# GUIDELINE DE DESARROLLO Y BUENAS PRÁCTICAS — HUG ME DUDES (Godot 4.x)

Este documento define los estándares de codificación, principios de diseño de software (SDD - Software Design Document), convenciones de nombrado, arquitectura de escenas y flujo de trabajo para el proyecto **Hug me dudes**.

---

## 1. PRINCIPIOS DE DISEÑO (SDD / CLEAN CODE)

### 1.1 Single Responsibility Principle (SRP)
- Cada script/nodo debe tener una única responsabilidad bien delimitada:
  - `Player`: Control de entrada, física de movimiento y animación de personaje.
  - `Status`: Almacenamiento puro de flags de estado (o máquina de estados formal).
  - `Disease`: Lógica de tiempo límite, muerte por aflicción y efectos visuales de una enfermedad específica.
  - `Game`: Orquestador de ronda, asignación de enfermedades, condición de victoria y ciclo de vida de la partida.
  - `Playlist` / `MusicPlayer`: Control de reproducción y pistas de audio.

### 1.2 Inversión de Dependencias y Desacoplamiento (Signals over Hard Coupling)
- **Regla de oro de Godot:** *"Llamar hacia abajo (llamadas a métodos en hijos), emitir hacia arriba (señales hacia padres/orquestadores)"*.
- Evitar rutas fijas como `get_node("../../hud/textWin")` o `$Timer.get_parent().get_parent()`.
- Usar señales (`signal player_infected(player, disease)`, `signal round_finished(winner)`) para comunicar cambios de estado hacia la escena principal o HUD.

### 1.3 Patrón State Machine para Jugador y Flujo de Juego
- Evitar variables booleanas sueltas y cruzadas (`isAlive`, `isDead`, `isAfflicted`, `isAttacking`).
- Usar enumeraciones (`enum State { IDLE, RUNNING, ATTACKING, HIT_STUN, AFFLICTED, DEAD }`) o nodos de estado dedicados para evitar estados inconsistentes (e.g., estar muerto pero seguir atacando o moviéndose).

### 1.4 Factory Pattern y Strategy Pattern para Enfermedades
- Mantener `DiseaseFactory` desacoplado, cargando dinámicamente o registrando recursos de enfermedades.
- Toda enfermedad extiende de una clase base abstracta `Disease` que implementa:
  - `start(duration: float)`
  - `apply_effects()`
  - `remove_effects()`
  - `on_death()`
  - `transfer_to(target_player)`

---

## 2. CONVENCIONES DE ESTILO Y GDSCRIPT (GODOT 4)

### 2.1 Tipado Estático Estricto (Static Typing)
- Declarar siempre tipos de datos en variables, parámetros de funciones y retornos:
  ```gdscript
  var speed: float = 200.0
  var is_alive: bool = true
  func infect(disease: Disease) -> bool:
  ```
- Evitar variables de tipo variante `var` sin tipar a menos que sea estrictamente dinámico.

### 2.2 Nombres de Archivos e Identificadores (GDScript Style Guide)
- **Archivos y carpetas:** `snake_case.gd`, `snake_case.tscn` (ej: `stage_select.gd`, `music_player.gd`, `spontaneous_combustion.gd`).
- **Clases:** `PascalCase` con `class_name` (ej: `class_name Player`, `class_name DiseaseFactory`).
- **Funciones y variables:** `snake_case` (ej: `check_victory_condition()`, `current_player_count`).
- **Constantes y Enums:** `UPPER_SNAKE_CASE` (ej: `MAX_PLAYERS`, `LIFE_EXPECTANCY`).
- **Variables privadas / internas:** Prefijo `_` (ej: `_is_ready`, `_apply_push()`).

### 2.3 Manejo de Nodos y Ciclo de Vida
- Usar `@onready var` para referencias a nodos hijos dentro de la misma escena.
- Conectar señales usando Callables seguros: `timer.timeout.connect(_on_timer_timeout)`.
- Liberar memoria con `queue_free()` en lugar de solo remover nodos del árbol.

---

## 3. ESPECIFICACIÓN DE SUBSISTEMAS Y REGLAS DE EXTENSIÓN

| Subsistema | Directorio | Propósito Principal | Buenas Prácticas Requeridas |
|---|---|---|---|
| **Main Orchestrator** | `Main.gd`, `Main.tscn` | Carga de pantallas, transición entre menú, selector de mapa y partida | Usar un autoloader / SceneManager centralizado con transiciones limpias |
| **Menu** | `src/game/menu.gd` | Lobby inicial, conexión de mandos/teclado y selección de personajes | Manejar desconexiones, asignación dinámica de `device_id` en input map |
| **Stage Select** | `src/game/stageSelect.gd` | Navegación de escenarios disponibles | Escaneo de recursos de mapas `.tscn` y carga asíncrona |
| **Partida (Game)** | `src/game/game.gd` | Spawn de jugadores, bucle de combate, contagio, verificación de victoria | No acoplarse directamente a nodos de HUD; emitir eventos de ronda |
| **Player** | `src/player/player.gd` | Movimiento 2D, estados, patada/empuje, retroceso (`knockback`) | State pattern, control de cooldowns con timers o acumuladores `delta` |
| **Enfermedades** | `src/disease/` | Aflicción aleatoria, cuenta atrás, muerte y traspaso | Herencia limpia de `Disease.gd`, partículas instanciadas con limpieza automática |
| **Audio / Playlist** | `src/playlist/` | BGM, jukebox OST, visualizador de audio spectrum | Autoload Singleton (`AudioManager`), listas basadas en `AudioStream` |

---

## 4. CHECKLIST ANTES DE CUALQUIER CAMBIO / FEATURE

1. **Revisar Contexto:** Consultar `.junie/context_summary.md` y `docs/SDD.md` antes de implementar.
2. **Respetar la Arquitectura:** No romper el desacoplamiento emitiendo señales hacia arriba.
3. **Manejar Edge Cases:**
   - ¿Qué pasa si 2 jugadores mueren en el mismo frame?
   - ¿Qué pasa si un jugador infectado se desconecta o cae en un hazard?
   - ¿Qué pasa si se transfieren enfermedades muy rápido (cooldown de contagio/inmunidad de 0.5s)?
4. **Documentar:** Actualizar la documentación si se altera alguna interfaz pública o estructura de carpetas.
