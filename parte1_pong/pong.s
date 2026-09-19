# ============================================================
# Pong en RISC-V para Ripes
#
# Jugador 1:
#   Arriba     -> subir
#   Izquierda  -> bajar
#
# Jugador 2:
#   Derecha    -> subir
#   Abajo      -> bajar
#
# Marcador:
#   Verde -> Jugador 1
#   Rojo  -> Jugador 2
# ============================================================

# Configuración de periféricos
    li s0, LED_MATRIX_0_BASE
    li s1, LED_MATRIX_0_WIDTH
    li s2, LED_MATRIX_0_HEIGHT
    li s5, D_PAD_0_BASE

# Posición inicial de las palas
    srli t0, s2, 1
    addi t0, t0, -1
    mv s3, t0
    mv s4, t0

# Estado de los botones
    li s6, 0
    li s7, 0
    li s8, 0
    li s9, 0

# Posición inicial de la pelota
    srli s10, s1, 1
    srli s11, s2, 1

# Dirección inicial de la pelota
    li a6, 1
    li a7, 1

# Contador de velocidad
    li a5, 0

# Marcador
# a3 = jugador 1
# a4 = jugador 2
    li a3, 0
    li a4, 0

# Dibujar estado inicial
    jal ra, draw_scores

    li a0, 1
    mv a1, s3
    li a2, 0x000000FF
    jal ra, draw_paddle

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x000000FF
    jal ra, draw_paddle

    mv a0, s10
    mv a1, s11
    li a2, 0x00FFFFFF
    jal ra, put_pixel

# ============================================================
# Bucle principal
# ============================================================

main_loop:

# Jugador 1: subir
    lw t0, 0(s5)
    beqz t0, up_released
    bnez s6, check_left

    li s6, 1

    # Límite superior: Y=0 se reserva para el marcador
    li t1, 1
    bge t1, s3, check_left

    # Borrar posición anterior
    li a0, 1
    mv a1, s3
    li a2, 0x00000000
    jal ra, draw_paddle

    addi s3, s3, -1

    # Dibujar nueva posición
    li a0, 1
    mv a1, s3
    li a2, 0x000000FF
    jal ra, draw_paddle

    j check_left

up_released:
    li s6, 0

# Jugador 1: bajar
check_left:

    lw t0, 8(s5)
    beqz t0, left_released
    bnez s7, check_right

    li s7, 1

    # Límite inferior
    addi t1, s2, -3
    bge s3, t1, check_right

    li a0, 1
    mv a1, s3
    li a2, 0x00000000
    jal ra, draw_paddle

    addi s3, s3, 1

    li a0, 1
    mv a1, s3
    li a2, 0x000000FF
    jal ra, draw_paddle

    j check_right

left_released:
    li s7, 0

# Jugador 2: subir
check_right:

    lw t0, 12(s5)
    beqz t0, right_released
    bnez s8, check_down

    li s8, 1

    # Límite superior
    li t1, 1
    bge t1, s4, check_down

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x00000000
    jal ra, draw_paddle

    addi s4, s4, -1

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x000000FF
    jal ra, draw_paddle

    j check_down

right_released:
    li s8, 0

# Jugador 2: bajar
check_down:

    lw t0, 4(s5)
    beqz t0, down_released
    bnez s9, update_ball

    li s9, 1

    # Límite inferior
    addi t1, s2, -3
    bge s4, t1, update_ball

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x00000000
    jal ra, draw_paddle

    addi s4, s4, 1

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x000000FF
    jal ra, draw_paddle

    j update_ball

down_released:
    li s9, 0

# ============================================================
# Movimiento de la pelota
# ============================================================

update_ball:

    addi a5, a5, 1

    # Control de velocidad de la pelota
    li t0, 200
    blt a5, t0, main_loop

    li a5, 0

    # Borrar posición anterior
    mv a0, s10
    mv a1, s11
    li a2, 0x00000000
    jal ra, put_pixel

# Rebote en borde superior
    li t0, 1
    bne s11, t0, check_bottom
    bge a7, zero, check_bottom

    li a7, 1

# Rebote en borde inferior
check_bottom:

    addi t0, s2, -1
    bne s11, t0, check_left_paddle
    bge zero, a7, check_left_paddle

    li a7, -1

# ============================================================
# Colisión con pala izquierda
# ============================================================

check_left_paddle:

    li t0, 2
    bne s10, t0, check_right_paddle

    # Solo comprobar si la pelota va hacia la izquierda
    bge a6, zero, check_right_paddle

    # Comprobar si la pelota está fuera de la pala
    blt s11, s3, point_for_right

    addi t1, s3, 2
    blt t1, s11, point_for_right

    # Rebote horizontal
    li a6, 1

    # Determinar dirección vertical según zona de impacto
    beq s11, s3, left_hit_top

    addi t1, s3, 1
    beq s11, t1, left_hit_middle

left_hit_bottom:
    li a7, 1
    j move_ball

left_hit_top:
    li a7, -1
    j move_ball

left_hit_middle:
    li a7, 0
    j move_ball

# ============================================================
# Colisión con pala derecha
# ============================================================

check_right_paddle:

    addi t0, s1, -3
    bne s10, t0, move_ball

    # Solo comprobar si la pelota va hacia la derecha
    bge zero, a6, move_ball

    # Comprobar si la pelota está fuera de la pala
    blt s11, s4, point_for_left

    addi t1, s4, 2
    blt t1, s11, point_for_left

    # Rebote horizontal
    li a6, -1

    # Determinar dirección vertical según zona de impacto
    beq s11, s4, right_hit_top

    addi t1, s4, 1
    beq s11, t1, right_hit_middle

right_hit_bottom:
    li a7, 1
    j move_ball

right_hit_top:
    li a7, -1
    j move_ball

right_hit_middle:
    li a7, 0
    j move_ball

# ============================================================
# Puntuación
# ============================================================

# Punto para jugador 2
point_for_right:

    addi a4, a4, 1

    li t0, 5
    bge a4, t0, player2_wins

    jal ra, draw_scores

    # Reiniciar pelota en el centro
    srli s10, s1, 1
    srli s11, s2, 1

    li a6, -1
    li a7, 1
    li a5, 0

    j draw_reset_ball

# Punto para jugador 1
point_for_left:

    addi a3, a3, 1

    li t0, 5
    bge a3, t0, player1_wins

    jal ra, draw_scores

    # Reiniciar pelota en el centro
    srli s10, s1, 1
    srli s11, s2, 1

    li a6, 1
    li a7, -1
    li a5, 0

    j draw_reset_ball

# Dibujar pelota después de un punto
draw_reset_ball:

    mv a0, s10
    mv a1, s11
    li a2, 0x00FFFFFF

    jal ra, put_pixel

    j main_loop

# Actualizar posición de la pelota
move_ball:

    add s10, s10, a6
    add s11, s11, a7

    mv a0, s10
    mv a1, s11
    li a2, 0x00FFFFFF

    jal ra, put_pixel

    j main_loop

# ============================================================
# Fin de partida
# ============================================================

player1_wins:

    # Pantalla verde
    li a0, 0x0000FF00
    jal ra, fill_screen

    j wait_restart

player2_wins:

    # Pantalla roja
    li a0, 0x00FF0000
    jal ra, fill_screen

    j wait_restart

# Esperar cualquier botón para reiniciar
wait_restart:

    lw t0, 0(s5)
    bnez t0, restart_game

    lw t0, 4(s5)
    bnez t0, restart_game

    lw t0, 8(s5)
    bnez t0, restart_game

    lw t0, 12(s5)
    bnez t0, restart_game

    j wait_restart

# Reiniciar partida
restart_game:

    jal ra, clear_screen

    # Reiniciar marcador
    li a3, 0
    li a4, 0

    # Reiniciar estado de botones
    li s6, 0
    li s7, 0
    li s8, 0
    li s9, 0

    # Centrar palas
    srli t0, s2, 1
    addi t0, t0, -1

    mv s3, t0
    mv s4, t0

    # Centrar pelota
    srli s10, s1, 1
    srli s11, s2, 1

    # Dirección inicial
    li a6, 1
    li a7, 1
    li a5, 0

    # Redibujar juego
    jal ra, draw_scores

    li a0, 1
    mv a1, s3
    li a2, 0x000000FF
    jal ra, draw_paddle

    addi a0, s1, -2
    mv a1, s4
    li a2, 0x000000FF
    jal ra, draw_paddle

    mv a0, s10
    mv a1, s11
    li a2, 0x00FFFFFF
    jal ra, put_pixel

    j main_loop

# ============================================================
# fill_screen
# Llena toda la matriz con el color recibido en a0.
# ============================================================

fill_screen:

    addi sp, sp, -16

    sw ra, 12(sp)
    sw s6, 8(sp)

    mv s6, a0
    li t3, 0

fill_row:

    bge t3, s2, fill_done

    li t4, 0

fill_column:

    bge t4, s1, next_fill_row

    mv a0, t4
    mv a1, t3
    mv a2, s6

    jal ra, put_pixel

    addi t4, t4, 1
    j fill_column

next_fill_row:

    addi t3, t3, 1
    j fill_row

fill_done:

    lw s6, 8(sp)
    lw ra, 12(sp)

    addi sp, sp, 16

    ret

# ============================================================
# clear_screen
# Apaga todos los LEDs de la matriz.
# ============================================================

clear_screen:

    addi sp, sp, -16

    sw ra, 12(sp)

    li t3, 0

clear_row:

    bge t3, s2, clear_done

    li t4, 0

clear_column:

    bge t4, s1, next_clear_row

    mv a0, t4
    mv a1, t3
    li a2, 0x00000000

    jal ra, put_pixel

    addi t4, t4, 1
    j clear_column

next_clear_row:

    addi t3, t3, 1
    j clear_row

clear_done:

    lw ra, 12(sp)

    addi sp, sp, 16

    ret

# ============================================================
# draw_scores
# Dibuja el marcador en la fila superior.
# ============================================================

draw_scores:

    addi sp, sp, -16
    sw ra, 12(sp)

    li t3, 0

# Limpiar fila del marcador
clear_score_row:

    bge t3, s1, draw_left_score

    mv a0, t3
    li a1, 0
    li a2, 0x00000000

    jal ra, put_pixel

    addi t3, t3, 1
    j clear_score_row

# Puntos del jugador 1
draw_left_score:

    li t3, 0

left_score_loop:

    bge t3, a3, draw_right_score

    li t5, 5
    bge t3, t5, draw_right_score

    li t4, 4
    add a0, t4, t3

    li a1, 0
    li a2, 0x0000FF00

    jal ra, put_pixel

    addi t3, t3, 1
    j left_score_loop

# Puntos del jugador 2
draw_right_score:

    li t3, 0

right_score_loop:

    bge t3, a4, score_done

    li t5, 5
    bge t3, t5, score_done

    addi t4, s1, -5
    sub a0, t4, t3

    li a1, 0
    li a2, 0x00FF0000

    jal ra, put_pixel

    addi t3, t3, 1
    j right_score_loop

score_done:

    lw ra, 12(sp)

    addi sp, sp, 16

    ret

# ============================================================
# draw_paddle
#
# a0 = posición X
# a1 = posición Y superior
# a2 = color
# ============================================================

draw_paddle:

    addi sp, sp, -16

    sw ra, 12(sp)
    sw s6, 8(sp)
    sw s7, 4(sp)
    sw s8, 0(sp)

    mv s6, a0
    mv s7, a1
    mv s8, a2

    # Pixel superior
    mv a0, s6
    mv a1, s7
    mv a2, s8
    jal ra, put_pixel

    # Pixel central
    mv a0, s6
    addi a1, s7, 1
    mv a2, s8
    jal ra, put_pixel

    # Pixel inferior
    mv a0, s6
    addi a1, s7, 2
    mv a2, s8
    jal ra, put_pixel

    lw s8, 0(sp)
    lw s7, 4(sp)
    lw s6, 8(sp)
    lw ra, 12(sp)

    addi sp, sp, 16

    ret

# ============================================================
# put_pixel
#
# a0 = X
# a1 = Y
# a2 = color
#
# Dirección = BASE + 4 * (Y * WIDTH + X)
# ============================================================

put_pixel:

    mul t2, a1, s1
    add t2, t2, a0
    slli t2, t2, 2
    add t2, s0, t2

    sw a2, 0(t2)

    ret
