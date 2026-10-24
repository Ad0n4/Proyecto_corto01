#!/usr/bin/env bash
# Compila Bubble Sort (C++) y Pong (ensamblador de Ripes) a RISC-V.
# No ejecuta los ELF: la traduccion a codigo maquina es el objetivo.

set -eo pipefail

DIR_SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RAIZ_PROYECTO="$(cd "$DIR_SCRIPT/.." && pwd)"
SALIDA="$DIR_SCRIPT/build"
RUTA_HERRAMIENTAS="/mnt/vol_NFS_rh003/Est_Digitales_2S_2026/tools_riscv"
SETUP="$RUTA_HERRAMIENTAS/riscv_tools_setup.sh"

# El servidor requiere cargar su entorno en cada terminal nueva.
if [[ -f "$SETUP" ]]; then
    # shellcheck disable=SC1090
    source "$SETUP"
fi

# Si el docente proporciono otro prefijo, se puede pasar RISCV_PREFIX.
PREFIJO="${RISCV_PREFIX:-}"
if [[ -z "$PREFIJO" ]]; then
    for candidato in riscv64-unknown-elf- riscv32-unknown-elf- riscv64-linux-gnu- riscv32-linux-gnu-; do
        if command -v "${candidato}gcc" >/dev/null 2>&1 && command -v "${candidato}g++" >/dev/null 2>&1; then
            PREFIJO="$candidato"
            break
        fi
    done
fi

if [[ -z "$PREFIJO" ]]; then
    echo "ERROR: No encuentro GCC/G++ para RISC-V." >&2
    echo "Cargue el entorno del profesor o defina RISCV_PREFIX." >&2
    exit 1
fi

CC="${PREFIJO}gcc"
CXX="${PREFIJO}g++"
OBJCOPY="${PREFIJO}objcopy"
OBJDUMP="${PREFIJO}objdump"

for herramienta in "$CC" "$CXX" "$OBJCOPY" "$OBJDUMP"; do
    if ! command -v "$herramienta" >/dev/null 2>&1; then
        echo "ERROR: Falta $herramienta" >&2
        exit 1
    fi
done

# Valores modificables si el toolchain trabaja con otra variante RISC-V.
ARQUITECTURA="${RISCV_ARCH:-rv32im}"
ABI="${RISCV_ABI:-ilp32}"
OPCIONES=(-march="$ARQUITECTURA" -mabi="$ABI")
mkdir -p "$SALIDA"

echo "Toolchain: $PREFIJO | Arquitectura: $ARQUITECTURA | ABI: $ABI"

# 1) C++: generar assembly, objeto ELF, ejecutable ELF y binario puro.
echo "[1/2] Compilando Bubble Sort en C++..."
"$CXX" "${OPCIONES[@]}" -std=c++17 -O0 -ffreestanding -fno-exceptions -fno-rtti -fno-pie -fno-stack-protector \
    -S "$DIR_SCRIPT/bubble_sort.cpp" -o "$SALIDA/bubble_sort_generado.s"
"$CXX" "${OPCIONES[@]}" -std=c++17 -O0 -ffreestanding -fno-exceptions -fno-rtti -fno-pie -fno-stack-protector \
    -c "$DIR_SCRIPT/bubble_sort.cpp" -o "$SALIDA/bubble_sort.o"
"$CXX" "${OPCIONES[@]}" -nostdlib -no-pie -Wl,-e,main -Wl,--no-relax \
    "$SALIDA/bubble_sort.o" -o "$SALIDA/bubble_sort.elf"
"$OBJCOPY" -O binary "$SALIDA/bubble_sort.elf" "$SALIDA/bubble_sort.bin"
"$OBJDUMP" -d "$SALIDA/bubble_sort.elf" > "$SALIDA/bubble_sort_desensamblado.txt"

# 2) Pong: adaptar solo los simbolos provistos por Ripes y ensamblar.
PONG_ORIGINAL="$RAIZ_PROYECTO/parte1_pong/pong.s"
if [[ ! -f "$PONG_ORIGINAL" ]]; then
    echo "ERROR: Falta $PONG_ORIGINAL" >&2
    echo "Coloque esta carpeta junto a parte1_pong dentro del repositorio." >&2
    exit 1
fi

echo "[2/2] Compilando Pong en ensamblador..."

# Estas constantes son SOLO para traducir el programa a instrucciones.
# El servidor Red Hat no dispone automaticamente de los perifericos Ripes.
# Para un mapa de memoria real, se deben suministrar valores verificados.
MATRIX_BASE="${LED_MATRIX_BASE:-0x00000000}"
MATRIX_WIDTH="${LED_MATRIX_WIDTH:-32}"
MATRIX_HEIGHT="${LED_MATRIX_HEIGHT:-32}"
DPAD_BASE="${D_PAD_BASE:-0x00000000}"

PONG_ADAPTADO="$SALIDA/pong_para_toolchain.s"
{
    printf '.section .text\n.globl _start\n_start:\n'
    printf '.equ LED_MATRIX_0_BASE, %s\n' "$MATRIX_BASE"
    printf '.equ LED_MATRIX_0_WIDTH, %s\n' "$MATRIX_WIDTH"
    printf '.equ LED_MATRIX_0_HEIGHT, %s\n' "$MATRIX_HEIGHT"
    printf '.equ D_PAD_0_BASE, %s\n' "$DPAD_BASE"
    cat "$PONG_ORIGINAL"
} > "$PONG_ADAPTADO"

"$CC" "${OPCIONES[@]}" -x assembler -c "$PONG_ADAPTADO" -o "$SALIDA/pong.o"
"$CC" "${OPCIONES[@]}" -nostdlib -no-pie -Wl,-e,_start -Wl,--no-relax \
    "$SALIDA/pong.o" -o "$SALIDA/pong.elf"
"$OBJCOPY" -O binary "$SALIDA/pong.elf" "$SALIDA/pong.bin"
"$OBJDUMP" -d "$SALIDA/pong.elf" > "$SALIDA/pong_desensamblado.txt"

echo
echo "Compilacion terminada. Resultados en $SALIDA"
echo "NOTA: los ELF/BIN muestran la traduccion a RISC-V; no se deben"
echo "ejecutar en Red Hat como aplicaciones ni sustituir el Pong de Ripes."
