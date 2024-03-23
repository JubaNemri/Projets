#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <stdlib.h>
#include <fcntl.h>
#include <pthread.h>
#include "foncts.h"

#define MAX_THREADS 4



void* resolution_limitee(void* arg) { //solution ou on limite le nombre de threads grace a mutex!

    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    int nombre_threads = 0;


    struct Arguments* arguments = (struct Arguments*)arg;
    if (arguments->entree.x < 0 || arguments->entree.x >= arguments->lignes || arguments->entree.y < 0 || arguments->entree.y >= arguments->colonnes || arguments->m[arguments->entree.x][arguments->entree.y] == 0) { //verifier si on est toujours dans la matrice et que ce n'est pas un mur
        pthread_exit(NULL);
    }
    if (arguments->m[arguments->entree.x][arguments->entree.y] == 3) { //condition d'arret, on se trouve sur la case sortie
        printf("Sortie trouvee en position : %d, %d!!!\n", arguments->entree.x, arguments->entree.y);
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



    pthread_t thread_id[MAX_THREADS];
    int nombre_threads_crees = 0;
    for (int i = 0; i < 4 && nombre_threads_crees < MAX_THREADS; i++) {
        pthread_mutex_lock(&mutex);
        if (nombre_threads < MAX_THREADS) {
            nombre_threads++;
            pthread_mutex_unlock(&mutex);
            pthread_create(&thread_id[i], NULL, resolution_limitee, &argthreads[i]);
            nombre_threads_crees++;
        } else {
            pthread_mutex_unlock(&mutex);
        }
    }
    for (int i = 0; i < nombre_threads_crees; i++) {
        pthread_join(thread_id[i], NULL);
    }
    arguments->m[arguments->entree.x][arguments->entree.y] = 1;
    pthread_mutex_lock(&mutex);
    nombre_threads--;
    pthread_mutex_unlock(&mutex);
    pthread_exit(NULL);
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
    pthread_create(&lethread, NULL, resolution_limitee, &args);
    pthread_join(lethread, NULL);

}
