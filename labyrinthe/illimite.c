#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <stdlib.h>
#include <fcntl.h>
#include <pthread.h>
#include "foncts.h"



int trouve= 0;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;


void* resolution_illimitee(void* arg) {
   
    if(trouve){ // si un des threads a deja trouvé la sortie, les autres créés entre temps n'ont plus à chercher
        pthread_exit(NULL);
    }


    struct Arguments* arguments = (struct Arguments*)arg;
    if (arguments->entree.x < 0 || arguments->entree.x >= arguments->lignes || arguments->entree.y < 0 || arguments->entree.y >= arguments->colonnes || arguments->m[arguments->entree.x][arguments->entree.y] == 0) { //verifier si on est toujours dans la matrice et que ce n'est pas un mur
        pthread_exit(NULL);
    }


    if (arguments->m[arguments->entree.x][arguments->entree.y] == 3) { //condition d'arret, on se trouve sur la case sortie
        pthread_mutex_lock(&mutex); //on utilise le muex pour contrer les acces concurrent a trouve et n'avoir qu'une seule sortie en cas de resolution en bloquant les threads concurrents
        trouve = 1;
        printf("Sortie trouvee en position : %d, %d!!!\n", arguments->entree.x, arguments->entree.y);
        pthread_mutex_unlock(&mutex); // on libere

        pthread_exit(NULL);//on arrete le thread
    }
    arguments->m[arguments->entree.x][arguments->entree.y] = 0; //on met a zero pour eviter les retours en arriere infinis, meilleure version que celle avec un tableau
    struct Position directions[4] = {
          {arguments->entree.x + 1,arguments->entree.y}, //bas
          {arguments->entree.x - 1, arguments->entree.y}, //haut
          {arguments->entree.x, arguments->entree.y + 1}, //droite
          {arguments->entree.x, arguments->entree.y - 1}}; //gauche

    struct Arguments argthreads[4] = {  //on cree les arguments que l'ont va passer aux threads
        {arguments->m, directions[0], arguments->lignes, arguments->colonnes},
        {arguments->m, directions[1], arguments->lignes, arguments->colonnes},
        {arguments->m, directions[2], arguments->lignes, arguments->colonnes},
        {arguments->m, directions[3], arguments->lignes, arguments->colonnes}};



    pthread_t lesthreads[4]; //on cree un tableau contenant les 4 threads qui vont s'occuper de la partie recherche(chaque thread s'occupe d'une position)
    for (int i = 0; i < 4; i++) {
        pthread_create(&lesthreads[i], NULL, resolution_illimitee, &argthreads[i]);
    }
    for (int i = 0; i < 4; i++) {
        pthread_join(lesthreads[i], NULL);
    }

    
    arguments->m[arguments->entree.x][arguments->entree.y] = 1; //on remet a un apres la fin d'execution avec d'autres Positions
    pthread_exit(NULL);//on arrete le thread a la fin de l'execution
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

    Arguments args = {m,entree,nbLignes, nbColonnes };
    pthread_t lethread;
    pthread_create(&lethread, NULL, resolution_illimitee, &args);
    pthread_join(lethread, NULL);
 

}

