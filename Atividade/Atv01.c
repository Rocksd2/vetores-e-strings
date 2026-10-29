#include <stdio.h>

int main() {
    int s1[5], s2[5];
    int soma1 = 0, soma2 = 0;   /* acumuladores das medias */

    /* Le os dois vetores e ja acumula os totais */
    for (int i = 0; i < 5; i++) {
        printf("Vetor 1 - numero %d: ", i + 1);
        scanf("%d", &s1[i]);
        printf("Vetor 2 - numero %d: ", i + 1);
        scanf("%d", &s2[i]);

        soma1 += s1[i];
        soma2 += s2[i];
    }

    /* Soma posicao por posicao, direto no printf */
    printf("\nSomas:\n");
    for (int i = 0; i < 5; i++) {
        printf("%d + %d = %d\n", s1[i], s2[i], s1[i] + s2[i]);
    }

    /* 5.0f forca a divisao real (com 5 seria divisao inteira) */
    printf("\nMedia vetor 1: %.2f\n", soma1 / 5.0f);
    printf("Media vetor 2: %.2f\n", soma2 / 5.0f);

    return 0;
}
