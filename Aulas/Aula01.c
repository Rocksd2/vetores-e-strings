// tema: Vetores | desc: Cria int v[5], imprime os índices e sobrescreve v[2]
#include <stdio.h>

int main(){
    int v[5] = {10, 20, 30, 40, 50};
            //   0   1   3  4   5


    printf("%d\n", v[0]);// 10
    printf("%d\n", v[4]);//50

    v[2] = 99; //muda o 3º
    printf("%d\n", v[2]);//99
    
    return 0;

}