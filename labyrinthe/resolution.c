#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <stdlib.h>
#include <fcntl.h>
#include "foncts.h"

//-- version essai ; ne fonctionne que si le nombre de lignes et le nombre de colonnes egales a 10 
int chemincorr[10][10] = {0}; //matrice pour le chemin de la sortie 


 int resolution(int **m, int x, int y,int lignes, int colonnes, Position *s) { 
    if (m[x][y] == 3) { //si on est sur la sortie
        chemincorr[x][y] = 1; //on met la fin du chemin a 1
        (*s).x = x; //on recup les coordonees du point
        (*s).y = y;
        return 1;
    }

    if (m[x][y] == 0 || chemincorr[x][y] == 1) { // si c'est un mur pour le 0 ||| quant a la deuxieme comparaison, elle sert a eviter les boucles infinies (retour en arriere puis avant puis arriere)
        return 0;
    }

    chemincorr[x][y] = 1;

    if (x + 1 < lignes && resolution(m, x + 1, y,lignes, colonnes, s)) { // bas
        return 1;
    }

    if (y + 1 < colonnes && resolution(m, x, y + 1,lignes, colonnes, s)) { // droite
        return 1;
    }

    if (x - 1 >= 0 && resolution(m, x - 1, y,lignes, colonnes, s)) { // haut
        return 1;
    }

    if (y - 1 >= 0 && resolution(m, x, y - 1,lignes, colonnes, s)) { // gauche
        return 1;
    }

    chemincorr[x][y] = 0; //si aucune des solutions disponibles, on rebrousse chemin grace au backtracking et on remet a 0 car il ne fera pas partie du chemin
    return 0;
}




void main()
{ int nbColonnes ; 
    int nbLignes ; 

    printf("Introduisez le nombre de colonnes  svp ! \n  : ");
    scanf("%d",&nbColonnes);
    
    printf("Introduisez le nombre de lignes svp ! \n  : ");
    scanf("%d",&nbLignes);

    int pid = fork() ;
    if (pid == 0 )
    {
        int file = open("resultat.txt", O_CREAT | O_WRONLY |O_TRUNC, 0644);
        if( !file )
            printf("impossible de créer le fichier résultat \n") ;
        

        // rediriger la sortie vers le fichier résultat.txt 

        dup2(file , 1);

        // convertir les nombres nbLignes et nbColonnes en chaine de caractères 

        char* arg1 = (char* ) malloc(sizeof(char)) ;
        char* arg2 = (char* ) malloc(sizeof(char)) ;

        sprintf(arg1 ,"%d",nbLignes) ;
        sprintf(arg2 ,"%d",nbColonnes) ;

        // exécuter la cammande "python3 generateur.py nbLignes nbColonnes "
        execl("/bin/python3","python3","/home/bob/Bureau/labyrinthe/generateur.py",arg1,arg2, NULL);
        exit(file) ;
    }  

    sleep(1);
    FILE *fichier = fopen("resultat.txt","r");
    int **m = CreerMatrice(nbLignes,nbColonnes,fichier) ;

    afficher(m, nbLignes, nbColonnes);
    Position entree = trouveentree(m, nbLignes,nbColonnes);
    printf("\n l'entree est : %d | %d\n", entree.x, entree.y);
    Position s;
    if (resolution(m, entree.x, entree.y,nbLignes, nbColonnes, &s)) {
        printf("Voila le chemin:\n");
        for (int i = 0; i < nbLignes; i++) {
            for (int j = 0; j < nbColonnes; j++) {
                printf("%d ", chemincorr[i][j]);
            }
            printf("\n");
        }
        printf("La solution est donc � la ligne %d, colonne %d ", s.x, s.y);
    }

}
