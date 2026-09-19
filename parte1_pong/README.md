# Parte 1 - Pong

Implementación de Pong en ensamblador RISC-V para ejecutarse en Ripes.

## Periféricos

- LED Matrix
- D-Pad

## Controles

| Jugador | Acción | Control |
|---|---|---|
| Jugador 1 | Subir | Arriba |
| Jugador 1 | Bajar | Izquierda |
| Jugador 2 | Subir | Derecha |
| Jugador 2 | Bajar | Abajo |

## Funcionamiento

Las palas se muestran en azul y la pelota en blanco. La fila superior de la matriz se utiliza como marcador:

- Verde: puntos del jugador 1.
- Rojo: puntos del jugador 2.

El primer jugador en alcanzar 5 puntos gana. Al finalizar la partida, la matriz muestra el color del ganador y cualquier botón del D-Pad permite reiniciar el juego.

## Ejecución

1. Abrir `pong.s` en Ripes.
2. Agregar los periféricos `LED Matrix` y `D-Pad`.
3. Ejecutar con Auto-clock.
4. Configurar Auto-clock en 1 ms.

## Archivos

- `pong.s`: programa principal.
- `video/enlace_video.txt`: enlace al video demostrativo.

El manual PDF se añadirá antes de la entrega final.
