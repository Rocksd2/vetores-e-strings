#include <stdio.h>
#include <string.h>

int main() {
    char a[20] = "banana";
    char b[20];
    int t = strlen(a);
    
    printf("%d\n", t); //6
    strcpy(b, a); // copia a em b
    if (strcmp(a, b) == 0) { // 0 = iguais
        printf("Iguais!\n");
    }

    return 0;
}
