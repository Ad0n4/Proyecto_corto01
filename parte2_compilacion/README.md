# Parte 2 - Compilacion mediante scripting

Esta carpeta contiene el programa Bubble Sort de cinco elementos en C++ y un script para compilarlo a RISC-V. El mismo script ensambla y enlaza `../parte1_pong/pong.s` del repositorio.

## Archivos

- `bubble_sort.cpp`: ordena el arreglo `{9, 2, 7, 1, 5}` y comprueba el resultado `{1, 2, 5, 7, 9}`.
- `compilar_riscv.sh`: genera codigo ensamblador, objetos, ELF, binarios y desensamblados en `build/`.
- `.gitignore`: evita subir archivos intermedios accidentalmente.

## Uso en el servidor del curso

El profesor debe crear una cuenta en el servidor Red Hat. La carpeta de trabajo indicada en el enunciado es:

```text
/mnt/vol_NFS_rh003/Est_Digitales_2S_2026/<usuario>/
```

El toolchain esta en `/mnt/vol_NFS_rh003/Est_Digitales_2S_2026/tools_riscv`. En cada terminal nueva se carga el entorno con:

```bash
source /mnt/vol_NFS_rh003/Est_Digitales_2S_2026/tools_riscv/riscv_tools_setup.sh
```

Desde la carpeta del proyecto, ejecute:

```bash
cd parte2_compilacion
bash compilar_riscv.sh
```

El script busca automaticamente compiladores `riscv64-unknown-elf-`, `riscv32-unknown-elf-`, `riscv64-linux-gnu-` o `riscv32-linux-gnu-`. Si la instalacion usa otro nombre, es posible indicar por ejemplo `RISCV_PREFIX=riscv64-unknown-elf- bash compilar_riscv.sh` (sustituyendo el prefijo por el real). Por defecto se generan instrucciones `rv32im` con ABI `ilp32`, parametros ajustables con `RISCV_ARCH` y `RISCV_ABI`.

## Resultados esperados

| Archivo | Proposito |
|---|---|
| `build/bubble_sort_generado.s` | Ensamblador producido por el compilador de C++. |
| `build/bubble_sort.o` | Codigo maquina RISC-V en formato ELF relocatable. |
| `build/bubble_sort.elf` | Archivo ELF enlazado, sin entorno de ejecucion. |
| `build/bubble_sort.bin` | Imagen binaria de las secciones cargables. |
| `build/bubble_sort_desensamblado.txt` | Desensamblado de instrucciones. |
| `build/pong_para_toolchain.s` | Copia adaptada para GNU assembler; el original no cambia. |
| `build/pong.o`, `build/pong.elf`, `build/pong.bin` | Productos de la compilacion de Pong. |
| `build/pong_desensamblado.txt` | Desensamblado del juego. |

Para comprobar la arquitectura:

```bash
file build/bubble_sort.elf build/pong.elf
```

Si se dispone de `readelf`:

```bash
readelf -h build/bubble_sort.elf
readelf -h build/pong.elf
```

Los ELF se enlazan sin biblioteca de inicio ni sistema operativo porque el objetivo es **generar y examinar codigo maquina**, no ejecutarlos como programas de Linux.

## Prueba opcional en Linux local

Para ver la salida ordenada en una PC que tenga `g++` convencional:

```bash
g++ -std=c++17 -DPRUEBA_LOCAL bubble_sort.cpp -o burbuja_local
./burbuja_local
```

Salida esperada:

```text
Resultado: 1 2 5 7 9
```

## Nota importante sobre Pong y Snake

El enunciado de la Parte 1 solicita `Pong`, pero el ultimo punto de la Parte 2 menciona `Snake`. Este material toma el **Pong construido en la Parte 1** como el programa ensamblador a compilar. Se recomienda confirmar con el profesor si la palabra `Snake` fue un error o si desea un programa distinto.

Asimismo, los identificadores `LED_MATRIX_0_BASE`, `D_PAD_0_BASE`, `LED_MATRIX_0_WIDTH` y `LED_MATRIX_0_HEIGHT` son especificos de Ripes. Para que GNU assembler pueda convertir las instrucciones a codigo maquina, el script crea una copia con constantes de sustitucion (direcciones base `0`, dimensiones `32x32` por defecto). **Son valores de relleno para compilar, no direcciones verificadas ni una configuracion ejecutable en Red Hat.** Para representar la configuracion real de Ripes deberan indicarse las constantes verdaderas, por ejemplo:

```bash
LED_MATRIX_BASE=0x... LED_MATRIX_WIDTH=... LED_MATRIX_HEIGHT=... D_PAD_BASE=0x... bash compilar_riscv.sh
```

No se pretende ejecutar el Pong como una aplicacion Linux convencional: su entrada/salida se realiza mediante perifericos mapeados en memoria por Ripes. El archivo `parte1_pong/pong.s` se conserva como fuente original del juego.
