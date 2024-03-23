#include <ctype.h>
typedef struct Position{
int x;
int y;
}Position; //structure pour donner abssice plus ordonnéé d'un point dans la matrice

typedef struct Arguments{ //structure contenant les arguments que l'on va passer aux threads
    int **m; //la matrice
    Position entree; //la position d'abord de l'entree puis ensuite au fur des threads des points autour
    int lignes;
    int colonnes;
}Arguments;



int** CreerMatrice( int ligne ,int colonne , FILE* fichier){

    int **M;char c;

    M = (int **) malloc((ligne)*sizeof(int*)) ;
    for(int i = 0 ; i <= ligne ; i++ )
        M[i] = (int *) malloc((colonne)*sizeof(int)) ;

    for(int i = 0 ; i < ligne ; i++ ){
        for(int j = 0 ; j < colonne ; j++ ){
            c = fgetc(fichier);
            while(!isdigit(c)){
        c = fgetc(fichier); }
            M[i][j] = c - '0';
}
}
    return M;
}

void afficher(int **m, int l, int c){
for(int i = 0; i < l; i++){
    for(int j = 0; j < c; j++){
        printf("%2d ", m[i][j]);
    }
    printf("\n");
}
}



Position trouveentree(int**m , int lignes, int colonnes){ //comme le nom l'indique trouver le 2 l'entree

    Position entree;
    for(int i = 0; i < lignes; i++){
        for(int j = 0; j < colonnes; j++){
            if(m[i][j] == 2){
                    printf("i : %d\n", i);
            printf("j : %d\n", j);
                entree.x = i;
                entree.y = j;
                return entree;
            }
        }
    }

}
