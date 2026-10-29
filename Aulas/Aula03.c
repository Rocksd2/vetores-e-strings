#include <stdio.h>

int main(){

    int v1[5];
    int v2[5];
    
    for(int i = 0; i < 5; i++){
        printf("Digite um numero: ");
        scanf("%d", &v1[i]);

        v2[i] = v1[i] * 2; 
    }
    for(int i = 0; i < 5; i++){
        printf("v1[%d]: %d\tv2[%d]: %d\n", i, v1[i], i, v2[i]);
    }

    return 0;
}