
# Parte 2 - Compilación RISC-V

## Descripción

Compilación de dos programas para la arquitectura RISC-V de 32 bits utilizando herramientas GNU y un script de Bash en Red Hat Enterprise Linux.

## Programas

### Bubble Sort

Programa en C++ que implementa el algoritmo de ordenamiento por burbuja sobre un arreglo de cinco elementos.

Arreglo original: 9, 5, 2, 7, 1

Arreglo ordenado: 1, 2, 5, 7, 9

### Pong

Programa en ensamblador RISC-V correspondiente a la Parte 1 del proyecto.

Para el ensamblado fuera de Ripes se utilizan valores provisionales para las constantes de los periféricos. El archivo objeto generado demuestra la traducción a código máquina, pero no permite ejecutar el juego directamente en Red Hat.

## Herramientas utilizadas

- Red Hat Enterprise Linux 8
- GNU RISC-V Toolchain de 32 bits
- GCC/G++ 12.1.0
- GNU Assembler
- GNU Objdump
- GNU Objcopy
- Bash

## Compilación

Configurar las herramientas:

```bash
export RISCV=/opt/riscv
export PATH="$RISCV/bin:$PATH"
```

Ejecutar el script:

```bash
chmod +x compilar_riscv.sh
./compilar_riscv.sh
```

El script compila ambos programas automáticamente.

## Archivos generados

### Bubble Sort

- `bubble_sort.cpp`: código fuente en C++.
- `bubble_sort.s`: ensamblador generado.
- `bubble_sort.o`: archivo objeto RISC-V.
- `bubble_sort.elf`: ejecutable ELF.
- `bubble_sort.bin`: código máquina binario.
- `bubble_sort_disasm.txt`: desensamblado.

### Pong

- `pong.s`: código fuente en ensamblador.
- `pong.o`: archivo objeto RISC-V.
- `pong_disasm.txt`: desensamblado.

## Resultados

Ambos programas fueron compilados correctamente mediante el script `compilar_riscv.sh`.

Se verificó que los archivos objeto corresponden a la arquitectura RISC-V de 32 bits y que contienen las instrucciones de máquina generadas.

La ejecución de Bubble Sort en un simulador RISC-V queda pendiente de verificar.

