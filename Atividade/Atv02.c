// tema: Atividade | desc: Lê 5 números e mostra o maior e o menor
#include <stdio.h>

int main(){
    int v[5];

    int maior, menor, i;

    printf("Digite 5 numeros:\n");
    scanf("%d %d %d %d %d", &v[0], &v[1], &v[2], &v[3], &v[4]);

    maior = menor = v[0];

    for(i = 1; i < 5; i++){
        if(v[i] > maior){
            maior = v[i];
        }
        if(v[i] < menor){
            menor = v[i];
        }
    }
    printf("Maior: %d\n", maior);
    printf("Menor: %d\n", menor);
}
