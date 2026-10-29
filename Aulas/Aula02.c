#include <stdio.h>

int main(){
    int idade[5];

    for(int i = 4; i >= 0; i--){

        printf("Digite a sua idade: ");
        scanf("%d", &idade[i]);

    }
    for(int i = 4; i >= 0; i--){

        printf("V[%d]: %d\n ", i, idade[i]);
    }
    return 0;
}