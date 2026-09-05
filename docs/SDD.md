# SOFTWARE DESIGN DOCUMENT (SDD) — HUG ME DUDES

**Proyecto:** Hug me dudes  
**Motor:** Godot Engine 4.x (GDScript)  
**Versión del Documento:** 1.0  
**Fecha:** Septiembre 2026  

---

## 1. INTRODUCCIÓN Y VISIÓN GENERAL DEL SISTEMA

### 1.1 Propósito
Este documento describe la especificación arquitectónica, los patrones de diseño, las estructuras de datos y el flujo de comunicación de los componentes de **Hug me dudes**. El objetivo es garantizar un desarrollo modular, desacoplado, mantenible y escalable para futuras mecánicas (nuevas enfermedades, nuevos mapas, habilidades de boicot, multijugador online/local extendido).

### 1.2 Descripción del Juego
Juego competitivo 2D de 3 a 4 jugadores en pantalla compartida. Un jugador recibe una enfermedad aleatoria con cuenta regresiva mortal y debe contagiar a otro cuerpo a cuerpo para salvarse. Los demás jugadores pueden evadir, bloquear o boicotear empujando o pateando a sus rivales hacia el infectado. El último superviviente gana.

---

## 2. ARQUITECTURA DEL SISTEMA

### 2.1 Diagrama de Arquitectura de Alto Nivel
```
+-------------------------------------------------------------+
|                         MAIN (Orchestrator)                 |
|  +-------------------------------------------------------+  |
|  | Scene Manager / Screen Transition Controller          |  |
|  +-------------------------------------------------------+  |
+------------------------------+------------------------------+
                               |
       +-----------------------+-----------------------+
       |                                               |
       v                                               v
+---------------+                             +-----------------+
|  LOBBY/MENU   |                             |   GAME SCENE    |
| - Device input|                             | (Game Manager)  |
| - Character   |                             +--------+--------+
|   selection   |                                      |
+---------------+              +-----------------------+-----------------------+
                               |                       |                       |
                               v                       v                       v
                      +-----------------+     +-----------------+     +-----------------+
                      | STAGE (World)   |     | PLAYERS (x3-x4) |     | DISEASE SYSTEM  |
                      | - Collisions    |     | - Kinematics    |     | - Timer/Death   |
                      | - Spawns        |     | - Kick / Push   |     | - Factory       |
                      | - Hazards/Spikes|     | - State Machine |     | - Visual FX     |
                      +-----------------+     +-----------------+     +-----------------+
                                                       |
                                                       v
                                              +-----------------+
                                              | CAMERA 2D (AABB)|
                                              | HUD / TEXT WIN  |
                                              | PLAYLIST / OST  |
                                              +-----------------+
```

---

## 3. ESPECIFICACIÓN DE MÓDULOS Y COMPONENTES

### 3.1 Módulo: Control y Física del Jugador (`Player`)
- **Tipo:** `CharacterBody2D`
- **Responsabilidades:**
  - Procesar entradas por dispositivo (`pad_1` .. `pad_4` / teclado).
  - Aplicar gravedad, aceleración horizontal, fricción y salto.
  - Ejecutar mecánicas de combate: patada con `RayCast2D` o hitbox frontal y retroceso (`push_vector`).
  - Responder a eventos de infección y muerte.
- **Patrón de Diseño Recomendado:** *Finite State Machine (FSM)*
  - `IDLE`: En reposo sobre el suelo.
  - `RUN`: En movimiento horizontal.
  - `JUMP / FALL`: En el aire.
  - `KICK`: Bloqueo momentáneo de movimiento mientras dura la animación de patada.
  - `STUNNED`: Desplazamiento forzado por empuje/patada recibida.
  - `DEAD`: Colisión reducida (`Constants.COLLISION_STATES.DEAD`), sin procesamiento de inputs.

### 3.2 Módulo: Sistema de Enfermedades (`Disease System`)
- **Tipo:** Jerarquía de nodos / Recursos desacoplados.
- **Patrones de Diseño:**
  - **Factory Method:** `DiseaseFactory` genera instancias basadas en catálogo o identificador.
  - **Strategy Pattern:** Cada aflicción concreta (`FulminatingDiarrhea`, `SpontaneousCombustion`, futuras como `ElectricShock`, `FreezingVirus`) encapsula sus propios tiempos, colores de tinte, partículas y comportamiento al morir.
- **Protocolo de Traspaso (Transfer Interface):**
  1. Jugador A (infectado) contacta a Jugador B (sano).
  2. Comprobar si B tiene inmunidad temporal de traspaso (cooldown de 0.5s para evitar rebotes continuos).
  3. `disease.transfer_to(player_b)`:
     - `player_a.status.isAfflicted = false`
     - `disease.remove_effects()`
     - `disease.afflicted = player_b`
     - `player_b.status.isAfflicted = true`
     - `disease.start_effects()`

### 3.3 Módulo: Orquestación de Partida (`Game`)
- **Tipo:** `Node2D`
- **Flujo de Ejecución:**
  1. `_ready()`: Configura el mundo, instancia el mapa seleccionado y posiciona a los jugadores.
  2. Temporizador de inicio de ronda (Countdown 3-2-1).
  3. Selección aleatoria del primer infectado vía `DiseaseFactory`.
  4. Bucle de supervisión:
     - Detección de caídas fuera del mapa o impactos con hazards (`Spike`).
     - Actualización de la lista de `alive_players`.
  5. Cuando `alive_players.size() == 1`:
     - Disparar señal `game_over(winner_player)`.
     - Invocar `TextWin` con animación.
     - Botón de revancha o vuelta a selección de mapa.

### 3.4 Módulo: Audio y Visualizador (`Playlist` / `MusicPlayer` / `Spectrum`)
- **Tipo:** Subsistema de Audio Centralizado.
- **Características:**
  - Lectura automática de archivos de música (`.ogg`) sin necesidad de hardcodear listas.
  - Reproducción con shuffle y autodetección de final de pista para transición continua.
  - Análisis de frecuencias en tiempo real usando el bus master de Godot con `AudioEffectSpectrumAnalyzerInstance`.

---

## 4. PATRONES DE COMUNICACIÓN Y EVENTOS (SIGNALS)

| Emisor | Señal | Parámetros | Receptor(es) | Acción |
|---|---|---|---|---|
| `Menu` | `match_started` | `(players_data: Dictionary)` | `Main` | Inicia la transición a selección de mapa o partida |
| `StageSelect` | `stage_selected` | `(stage_path: String)` | `Main` | Carga el mapa elegido y pasa a `Game` |
| `Player` | `player_died` | `(player: Player)` | `Game` | Actualiza la cuenta de jugadores vivos |
| `Player` | `player_hit` | `(victim: Player, attacker: Player)` | `Game`, `FX` | Aplica empuje y evalúa posible contagio |
| `Disease` | `disease_expired` | `(afflicted_player: Player)` | `Player`, `Game` | Ejecuta la muerte del jugador infectado |
| `Game` | `round_won` | `(winner: Player)` | `Hud`, `TextWin` | Presenta la pantalla de victoria |

---

## 5. ROADMAP DE MEJORAS Y REFACTORIZACIONES SUGERIDAS

1. **Migración completa a Godot 4 Idioms:**
   - Estandarizar `CharacterBody2D.move_and_slide()` sin argumentos.
   - Reemplazar cadenas duras de rutas (`res://...`) por `StringName` o `preload` constantes tipadas.
2. **Buffer de Inmunidad Post-Traspaso:**
   - Implementar un temporizador de inmunidad de contagio de 0.5s en el jugador que acaba de traspasar la enfermedad para evitar que el receptor se la devuelva instantáneamente sin reacción.
3. **Gestión Unificada de Entradas (Input Map):**
   - Centralizar las acciones en `InputMap` (ej: `p1_left`, `p1_right`, `p1_jump`, `p1_kick`, `p2_...`) permitiendo remapeo y asignación flexible.
4. **Nuevas Enfermedades:**
   - *Parálisis Temporal:* Reduce la velocidad del infectado paulatinamente mientras baja el reloj.
   - *Gravedad Invertida:* Invierte el salto o empuja al techo.
