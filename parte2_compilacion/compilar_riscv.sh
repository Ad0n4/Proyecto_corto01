
#!/bin/bash
set -e

# Configuración del toolchain RISC-V
export RISCV=/opt/riscv
export PATH="$RISCV/bin:$PATH"

echo "Compilando Bubble Sort..."

# Generar ensamblador desde C++
riscv32-unknown-elf-g++ -O0 -S bubble_sort.cpp -o bubble_sort.s

# Generar archivo objeto
riscv32-unknown-elf-g++ -O0 -c bubble_sort.cpp -o bubble_sort.o

# Generar ejecutable ELF
riscv32-unknown-elf-g++ -O0 bubble_sort.cpp -o bubble_sort.elf

# Generar binario
riscv32-unknown-elf-objcopy -O binary bubble_sort.elf bubble_sort.bin

# Generar desensamblado
riscv32-unknown-elf-objdump -d bubble_sort.elf > bubble_sort_disasm.txt

echo "Bubble Sort compilado correctamente."

echo "Compilando Pong..."

# Ensamblar programa RISC-V
riscv32-unknown-elf-as -march=rv32im -mabi=ilp32 \
    --defsym LED_MATRIX_0_BASE=0 \
    --defsym LED_MATRIX_0_WIDTH=32 \
    --defsym LED_MATRIX_0_HEIGHT=32 \
    --defsym D_PAD_0_BASE=0 \
    -o pong.o pong.s

# Generar desensamblado
riscv32-unknown-elf-objdump -d pong.o > pong_disasm.txt

echo "Pong ensamblado correctamente."
echo "Compilacion finalizada."



