# Proyecto Corto 01 - Diseño de Sistemas Digitales

Proyecto grupal desarrollado en RISC-V.

## Estructura

```text
Proyecto_corto01/
├── README.md
├── parte1_pong/
│   ├── README.md
│   ├── pong.s
│   └── video/
│       └── enlace_video.txt
└── parte2_compilacion/
    └── README.md
```

## Parte 1 - Pong

Juego Pong implementado en ensamblador RISC-V utilizando Ripes, una matriz LED y un D-Pad.

### Controles

**Jugador 1**
- Arriba: subir pala
- Izquierda: bajar pala

**Jugador 2**
- Derecha: subir pala
- Abajo: bajar pala

### Funcionalidades

- Dos jugadores.
- Movimiento automático de la pelota.
- Colisiones con las palas.
- Rebote según la zona de impacto.
- Marcador visual en la matriz LED.
- Partida a 5 puntos.
- Pantalla de victoria.
- Reinicio de partida.

### Archivos

- `parte1_pong/pong.s`: código fuente del juego.
- `parte1_pong/README.md`: descripción y uso de la Parte 1.
- `parte1_pong/video/enlace_video.txt`: enlace al video demostrativo.

El manual en PDF se agregará antes de la entrega final.

## Parte 2 - Compilación

La segunda parte del proyecto se desarrollará en `parte2_compilacion/`.
