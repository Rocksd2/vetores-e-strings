#include <stdio.h>

int soma_vetor(int v[], int n){
    int soma = 0;
    for(int i = 0; i < n; i++){
        soma += v[i];
    }
    return soma;
}

int main(){
    int v[100];
    int n;

    printf("Quantos valores voce quer somar? ");
    scanf("%d", &n);

    for(int i = 0; i < n; i++){
        printf("Digite o %d valor: ", i + 1);
        scanf("%d", &v[i]);
    }

    int resultado = soma_vetor(v, n);
    printf("A soma e: %d\n", resultado);
    return 0;
}
