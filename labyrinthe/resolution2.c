#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <stdlib.h>
#include <fcntl.h>
#include "foncts.h"


//autre version de la resolution, celle ci est plus efficace mais on n'obtient pas le chemin vers la sortie.


int trouve = 0; // int qui fait office de booleen qui permet de determiner si la sortie a deja ete trouvee.


   int resolution2(int **m, int x, int y,int lignes, int colonnes, Position *s) { 

       if(trouve){
        return 0;
       }
    if (m[x][y] == 3) { //si on est sur la sortie
        trouve = 1;
        (*s).x = x; //on recup les coordonees du point
        (*s).y = y;

        printf("sortie trouvee en %d ,  %d\n", x, y);
        return 1;
    }

    if (m[x][y] == 0) {
        return 0;
    }

    m[x][y] = 0;

    if (x + 1 < lignes && resolution2(m, x + 1, y,lignes, colonnes, s)) { // bas
        return 1;
    }

    if (y + 1 < colonnes && resolution2(m, x, y + 1,lignes, colonnes, s)) { // droite
        return 1;
    }

    if (x - 1 >= 0 && resolution2(m, x - 1, y,lignes, colonnes, s)) { // haut
        return 1;
    }

    if (y - 1 >= 0 && resolution2(m, x, y - 1, lignes, colonnes, s)) { // gauche
        return 1;
    }

    m[x][y] = 1;
    return 0;
}




void main()
{
    int nbColonnes ; 
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
    resolution2(m, entree.x, entree.y,nbLignes, nbColonnes, &s);
        

}
