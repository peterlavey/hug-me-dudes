# Hug Me Dudes 🦠🏃💨

Un juego 2D multijugador local (3 a 4 jugadores) competitivo y frenético desarrollado en **Godot Engine 4.x**.

---

## 🎮 Concepto del Juego

Un grupo de amigos se enfrenta en una arena cerrada. De forma imprevista, uno de ellos contrae una **enfermedad letal aleatoria** con un temporizador de cuenta regresiva.

- **El Infectado:** Debe perseguir a sus rivales y tocarlos/patearlos para transferirles la enfermedad y salvarse antes de que expire el tiempo y muera.
- **Los Supervivientes:** Deben huir desesperadamente, pero también pueden **boicotear, empujar o patear** a sus compañeros para hacerlos tropezar y ser alcanzados por el infectado.
- **Victoria:** ¡El último jugador con vida gana la partida!

---

## 🕹️ Controles Básicos (Lobby / Teclado)

- **Movimiento:** Teclas `A` / `D` o Cruceta / Joystick en gamepad.
- **Salto:** Tecla `W` o botón A / Cruz en gamepad.
- **Patada / Empuje / Aceptar:** Tecla `F` o botón X / Cuadrado en gamepad.
- **Cancelar / Volver:** Tecla `G` o botón B / Círculo en gamepad.

---

## 📂 Estructura del Proyecto

```text
hug-me-dudes/
├── .junie/                 # Directrices de desarrollo y memoria de contexto
│   ├── guidelines.md       # Reglas de clean code, convenciones y patrones
│   └── context_summary.md  # Detalle funcional de cada subsistema
├── docs/
│   └── SDD.md              # Software Design Document (Arquitectura, FSM, Signals)
├── particles/              # Efectos visuales (Fuego, Diarrea, etc.)
├── sounds/                 # Efectos de sonido y OST jukebox
├── sprites/                # Spritesheets y animaciones de personajes y UI
├── stages/                 # Escenarios, mapas y recursos de nivel
├── src/
│   ├── characters/         # Definición de personajes
│   ├── disease/            # Factory y clases de enfermedades
│   ├── game/               # Menú, selección de mapa, cámara y game loop
│   ├── player/             # Cinemática, estados y colisiones del jugador
│   ├── playlist/           # Reproductor de música y analizador de espectro
│   └── utils/              # Funciones auxiliares de archivos y carpetas
├── Main.tscn / Main.gd     # Orquestador principal de escenas
└── project.godot           # Configuración del motor Godot
```

---

## 📚 Documentación de Diseño y Directrices

- [Software Design Document (SDD)](docs/SDD.md)
- [Guidelines y Buenas Prácticas](.junie/guidelines.md)
- [Contexto de Funcionalidades](.junie/context_summary.md)
