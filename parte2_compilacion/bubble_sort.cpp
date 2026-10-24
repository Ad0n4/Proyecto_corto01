// Ordenamiento de burbuja de cinco numeros.
// Se compila para RISC-V sin depender de bibliotecas de E/S.

#ifdef PRUEBA_LOCAL
#include <iostream>
#endif

volatile int numeros[5] = {9, 2, 7, 1, 5};

void bubble_sort(volatile int arreglo[], int longitud) {
    for (int i = 0; i < longitud - 1; ++i) {
        for (int j = 0; j < longitud - i - 1; ++j) {
            int actual = arreglo[j];
            int siguiente = arreglo[j + 1];

            if (actual > siguiente) {
                arreglo[j] = siguiente;
                arreglo[j + 1] = actual;
            }
        }
    }
}

extern "C" int main() {
    bubble_sort(numeros, 5);

#ifdef PRUEBA_LOCAL
    std::cout << "Resultado: ";
    for (int i = 0; i < 5; ++i) {
        std::cout << numeros[i] << (i == 4 ? '\n' : ' ');
    }
#endif

    const int esperado[5] = {1, 2, 5, 7, 9};
    for (int i = 0; i < 5; ++i) {
        if (numeros[i] != esperado[i]) {
            return 1;
        }
    }
    return 0;
}
