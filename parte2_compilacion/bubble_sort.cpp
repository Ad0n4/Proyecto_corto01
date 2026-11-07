
#include <iostream>
using namespace std;

int main() {
    int numeros[5] = {9, 5, 2, 7, 1};
    int auxiliar;

    // Ordenamiento por burbuja
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4 - i; j++) {
            if (numeros[j] > numeros[j + 1]) {
                auxiliar = numeros[j];
                numeros[j] = numeros[j + 1];
                numeros[j + 1] = auxiliar;
            }
        }
    }

    // Mostrar arreglo ordenado
    for (int i = 0; i < 5; i++) {
        cout << numeros[i] << " ";
    }

    cout << endl;

    return 0;
}

