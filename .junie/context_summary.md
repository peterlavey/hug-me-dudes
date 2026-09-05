# CONTEXTO FUNCIONAL Y ARQUITECTURA DE CADA SUBSISTEMA

Este documento almacena el mapa de conocimiento completo de cada subsistema de **Hug me dudes** para evitar rescaneos en futuras sesiones y permitir una comprensión instantánea.

---

## CONTEXTO NARRATIVO Y GAMEPLAY CORE
- **Género:** Party game competitivo 2D / Local multiplayer (3 a 4 jugadores).
- **Mecánica Core (Hot Potato / Tag):**
  - Una enfermedad letal aleatoria infecta a un jugador con un temporizador regresivo.
  - El jugador infectado debe perseguir y tocar/golpear a otro jugador para transferirle la enfermedad y curarse a sí mismo antes de que el temporizador llegue a cero.
  - Al expirar el tiempo, el infectado muere.
  - Los jugadores sanos pueden boicotear, empujar o golpear a sus compañeros con una patada para desestabilizarlos o empujarlos hacia el infectado.
  - El último jugador con vida gana la partida.

---

## SUBSISTEMAS Y DETALLE DE CADA COMPONENTE

### 1. Menú Principal y Lobby (`src/game/menu.gd`, `src/game/menu.tscn`)
- **Responsabilidad:** Registro de jugadores (Player 1 a 4), selección de personajes (`Wyrm`, `Peter`, `Bestian`, `Kenny`), soporte para teclado y múltiples gamepads.
- **Flujo y Mecánica:**
  - `_input(event)`: Detecta entradas por teclado (W/A/S/D/F/G) y mandos (`joy_connection_changed`, botones y D-Pad).
  - Maneja slots (`player_1`, `player_2`, `player_3`, `player_4`) y columnas de selección visual.
  - Cada jugador puede ciclar entre los 4 skins disponibles y pulsar "Aceptar / Seleccionar" para quedar listo (`isReady = true`).
  - Cuando los jugadores listos son $\ge 2$ (soporte para 3 o 4 jugadores), y se presiona Enter/Start, emite `start` o llama a la transición hacia la selección de escenario.
- **Puntos clave de mejora:** Manejo de desconexiones en caliente, persistencia limpia de datos de jugadores (`player_data` dictionary/resource) y migración a Input Actions estándar en lugar de `InputEventKey` con Scancodes duros.

---

### 2. Selección de Escenario (`src/game/stageSelect.gd`, `src/game/stageSelect.tscn`)
- **Responsabilidad:** Selector visual y cargador de mapas jugables.
- **Flujo y Mecánica:**
  - Usa `FolderManager` para escanear `res://stages` buscando archivos `.tscn` de escenarios.
  - Muestra un grid/carrusel de preview del mapa con controles de navegación (Izquierda/Derecha/Aceptar).
  - Al confirmar, emite la señal / invoca la carga de `Game.tscn` pasando la ruta del escenario seleccionado y la configuración de jugadores.

---

### 3. Partida Principal (Game Loop / Orquestador de Ronda) (`src/game/game.gd`, `src/game/game.tscn`)
- **Responsabilidad:** Coordinador central de la ronda, spawn de mapa, spawn de personajes, asignación de enfermedades y resolución de victoria.
- **Flujo y Mecánica:**
  - Instancia el escenario seleccionado en un nodo contenedor.
  - Lee los puntos de aparición (`spawn_1`, `spawn_2`, `spawn_3`, `spawn_4`) definidos en el escenario o calculados.
  - Instancia las entidades de `Player` asignándoles su Skin, esquema de Input (`pad_1`, `pad_2`, etc.) y posición inicial.
  - Inicia la música de fondo (`Playlist`).
  - **Infección inicial:** Tras un breve retardo de inicio (e.g. 2 segundos), elige un jugador vivo aleatorio e invoca `DiseaseFactory.get_random_disease()` para infectarlo.
  - **Detección de Colisiones entre Jugadores:** Ejecuta chequeos por proximidad/colisión o eventos de contacto entre `CharacterBody2D`.
    - Si un jugador infectado colisiona con uno sano (o le da una patada), se transfieren los efectos y el timer.
  - **Condición de Fin de Partida:** Monitorea el contador de jugadores vivos (`alive_players`).
    - Cuando `alive_players == 1`, se activa el estado de victoria, se muestra `TextWin.gd` con el nombre/skin del ganador y se ofrece reiniciar o volver al menú.

---

### 4. Cámara Dinámica Multijugador (`src/game/camera.gd`)
- **Responsabilidad:** Cámara compartida en tiempo real que encuadra dinámicamente a todos los jugadores activos.
- **Mecánica:**
  - Itera sobre todos los jugadores vivos y calcula la caja envolvente (AABB / Bounding Box) con sus posiciones `global_position`.
  - Centra el punto de vista en el promedio vectorial $(X_{min} + X_{max})/2, (Y_{min} + Y_{max})/2$.
  - Ajusta el `zoom` con suavizado (`lerp`) para mantener a todos los jugadores visibles dentro de los márgenes mínimos y máximos.

---

### 5. Entidad Jugador (`src/player/player.gd`, `src/player/status.gd`, `src/player/constants.gd`)
- **Responsabilidad:** Controlador cinemático 2D, animaciones, estado físico, mecánicas de empuje y patada.
- **Componentes:**
  - **Movimiento:** `velocity`, `SPEED`, `GRAVITY`, `JUMP_FORCE`. Salto con gravedad de Godot 4.
  - **Ataque / Patada (`kick`):**
    - Al presionar el botón de ataque, activa animación de patada y un `RayCast2D` o `Area2D` frontal.
    - Si detecta a otro jugador, aplica fuerza de empuje (`push_vector` / `knockback`) en la dirección correspondiente.
    - Si el atacante o el atacado están infectados, el contacto puede provocar la transmisión de la aflicción.
  - **Estados (`Status.gd`):** Flags `isAlive`, `isDead`, `isAfflicted`, `isAttacking`.
  - **Colisiones (`Constants.gd`):** Modifica el tamaño y offset del `CollisionShape2D` al pasar de estado vivo a muerto (cadáver en el suelo).
  - **Muerte (`dead()`):** Desactiva controles de movimiento, reproduce animación de muerte y notifica al GameManager.

---

### 6. Sistema de Enfermedades (`src/disease/`)
- **Arquitectura:**
  - `Disease.gd`: Clase base que contiene un `Timer` interno y un display visual (`timeLeft`). Al expirar (`timeout`), llama a `dead()`, matando al jugador afligido (`afflicted.dead()`).
  - `DiseaseFactory.gd`: Catálogo y generador aleatorio de aflicciones.
- **Enfermedades Implementadas:**
  1. `SpontaneousCombustion.gd`:
     - Tiempo de vida: ~6 segundos.
     - Efecto visual: Partículas de fuego (`Fire.tscn`) emitiendo desde el jugador y cambio de modulación a ceniza (`#333333`).
  2. `FulminatingDiarrhea.gd`:
     - Tiempo de vida: ~5 segundos.
     - Efecto visual: Partículas de diarrea (`Diarrhea.tscn`) y modulación verdosa (`#4d732a` / `#2d7550`).
- **Mecánica de Contagio:**
  - Al transferir, se desvinculan las partículas del emisor (`remove_effects()`), se detiene su aflicción, y se re-ancla la enfermedad con el tiempo restante al nuevo jugador receptor (`start_effects()`).

---

### 7. Gestor de Música y Audio (`src/playlist/`)
- **Responsabilidad:** Jukebox de música de fondo, reproducción aleatoria de pistas OST y visualización de espectro de frecuencias.
- **Componentes:**
  - `Playlist.gd`: Lee archivos `.ogg` de `res://sounds/ost` mediante `FolderManager` y configura la cola de reproducción.
  - `MusicPlayer.gd`: `AudioStreamPlayer2D` / `AudioStreamPlayer` con shuffle, autodetección de fin de pista y notificación en pantalla del título de la canción.
  - `Spectrum.gd`: Dibuja mediante `_draw()` barras de espectro reactivo utilizando `AudioServer.get_bus_effect_instance()` y transformadas FFT de frecuencias.
  - `SpotifyAPI.gd`: Cliente HTTP experimental para integración externa.

---

### 8. HUD, Transiciones y Ganador (`src/game/hud.gd`, `src/game/transition.gd`, `src/game/textWin.gd`)
- **`Transition.gd`:** Efectos visuales de fundido (`Fade In / Fade Out`) entre escenas usando `ColorRect` y tweens.
- **`TextWin.gd`:** Pantalla de anuncio de victoria (`Label` / animación) destacando al superviviente.
- **`Hud.gd`:** Interfaz en partida mostrando temporizadores globales y estado de los jugadores.

---

### 9. Escenarios y Elementos Interactivos (`stages/`)
- Escenario base: `stages/resources/ship/Ship.tscn`.
- Trampas / Obstáculos: `stages/resources/Spike.gd` (pinchos de daño/muerte instantánea).
- Layouts de plataformas con tilesets y colisiones 2D estáticas.
