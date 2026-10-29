#include <stdio.h>
#include <string.h>

int main() {
    char nome[30];

    printf("Qual seu nome?\n");
    fgets(nome, 30, stdin);

    nome[strcspn(nome, "\n")] = '\0';

    int n = strlen(nome);

    printf("Ola, %s\n", nome);
    printf("Quantidade de caracteres: %d\n", n);

    return 0;
}