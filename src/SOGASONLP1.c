/* ===========================================================
   Xavier Gandibleux
   Metaheuristique fondee sur une algorithme genetique simple
   Probleme traite : SO-NLP sans contrainte
   2012
   =========================================================== */


/* Librairies a inclure ====================================== */

  #include <stdio.h>
  #include <math.h>
  #include "rnd.c"


/* Constantes ================================================ */

  #define interactif     0    // 1 : oui / 0 : non

  #define nPoints        300   // Nombre de points dans la population DOIT ETRE UN NOMBRE PAIR
  #define lBit           25   // Representation d'un individu (nombre de bits)

  #define randomseed     0.95  // semence du generateur aleatoire

  #define probaCrossover 0.80 // probabilite d'acceptation d'un crossover a un point entre 2 individus
  #define probaMutation  0.30 // probabilite d'acceptation d'une mutation d'un bit d'un individu
  #define nGeneration    1100//50   // nombre de generation a realiser

/* Structures ================================================ */

  typedef struct        // information d'un individu
  {

  	// valeur codee en binaire d'une variable de decision
	int       bx[lBit];
	int       bx2[lBit];
	// valeur variable decision
	double    x;
	double    x2;
	// valeur f1(x)
	double    f1;

  } sIndividu;



/* =========================================================== */
/* Point d entree principal ================================== */

  int main(void)
  {
	  // indices sur vecteurs
	  int i,j,i2;

	  // definition d'une population d'individu
	  sIndividu  pop[nPoints];         // population courante
	  sIndividu  popSelected[nPoints]; // population selectionnee

	  // decodage d'un individu
	  long int puis;
	  long int xPrim;
	  long int xPrim2;

	  // Roulette de selection
	  double sommeFitness;
	  double roulette[nPoints];    // Roulette pour la selection
	  double tirage1;
	  double tirage2;
	  int individu1;
	  int individu2;
	  sIndividu enfant1;
	  sIndividu enfant2;
	  double x,y,z;

	  double fitnessAvg[nGeneration];

	  double min;
	  int   imin;

	  // indexation indirecte pour realiser le shuffle
	  int permutid[nPoints], permut[nPoints];

	  // variables pour les operateurs d'evolution
	  double proba;   // probabilite tiree
	  int cut;        // point de coupe du crossover
	  int bit;        // bit flippe pour la mutation
	  int generation; // generation courante

	  // fichier de sortie
	  FILE * f;

    /* ------------------------------------------------------- */

  	  randomizeFixed(randomseed);


    /* ------------------------------------------------------- */
	/* Initialisation de la population : tout aleatoire */

	  printf("\n = = = = = = = = = = = = = = POPULATION INITIALE = = = = = = = = = = = = = = \n");

	  for(i=0;i<nPoints;i++)
	  {
		for(j=0;j<lBit;j++)
		  {
			  pop[i].bx[j] = rnd(0,1);
			  pop[i].bx2[j] = rnd(0,1);
		  }

		/* for(j=0;j<lBit;j++)
		 {
		 	printf("%d",pop[i].bx[j]);
		 }
		 printf("\n");
		 */
	  }


    /* ------------------------------------------------------- */
	/* calcul et affichage de la population initiale */

	  f = fopen("MHsop1init.dat", "w");

	  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");
	  for(i=0;i<nPoints;i++)
	  {
		  // decode la variable x et memorise les resultats
		  xPrim = 0; xPrim2 = 0; puis= 1;
		  for(j=lBit;j!=0;j--)
		  {  xPrim = xPrim + (long int)(pop[i].bx[j-1]) * puis;
			  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
			  puis = 2 * puis;
		  }

		  // decode la variable x2 et memorise les resultats
		  puis= 1;
		  for(j=lBit;j!=0;j--)
		  {  xPrim2 = xPrim2 + (long int)(pop[i].bx2[j-1]) * puis;
			  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
			  puis = 2 * puis;
		  }

 	      pop[i].x = -10.0 + (double)(xPrim) * 20.0/(33554432.0 - 1.0);
 	      pop[i].x2 = -10.0 + (double)(xPrim2) * 20.0/(33554432.0 - 1.0);

		  pop[i].f1 =  pow((pop[i].x + 2 * pop[i].x2 - 7),2) + pow((2 * pop[i].x + pop[i].x2 - 5),2) ;

		  //edite les resultats
		  printf("%3d \t",i+1);
		  for(j=0;j<lBit;j++){
		  	printf("%d",pop[i].bx[j]);
		  }
		  printf("\t");
		  for(j=0;j<lBit;j++){
		  	printf("%d",pop[i].bx2[j]);
		  }
		  printf("\t");

		  printf("%6.3f \t",pop[i].x);
		  printf("%6.3f \t",pop[i].x2);
		  printf("%6.3f \t",pop[i].f1);
		  printf("\n");

		  fprintf(f,"%4d %6.3f %6.3f %6.3f\n",i, pop[i].x, pop[i].x2, pop[i].f1);

	  }
	  fclose(f);

	  /* ------------------------------------------------------- */
	  /* Boucle de generation */

for (generation=0; generation<nGeneration; generation++)
{
	  printf("\n =========================== GENERATION %3d =========================== \n",generation+1);

	fitnessAvg[generation]=0.0;

	  /* ------------------------------------------------------- */
	  /* Roulette */

	  printf("\n = = = = = = = = = = = = = = ROULETTE %3d = = = = = = = = = = = = = = \n",generation+1);

  	  printf("\n");


	  // Identifie le minima sur f1 !!! necessite une population d'au moins 2 points !!!
	  min = pop[0].f1;
	  for(i=1;i<nPoints;i++)
	  {
		if(pop[i].f1 < min)
		{
			min = pop[i].f1;
			imin = i;
		}
	  }
	  printf(" fmin : %8.3f imin : %d \n\n",min,imin+1);

 	  if (min < 0){
 	  	min=-min;
 	  }
 	  else {
 	  	min=0;
 	  }

	  // Elabore la roulette
	  sommeFitness = 0;
	  for(i=0; i<nPoints; i++)
		{
			roulette[i] = sommeFitness + pop[i].f1 + min;
			sommeFitness = sommeFitness + pop[i].f1 + min;
		}

	  for(i=0; i<nPoints; i++){
	  	printf("%3d\t",i+1);
	  	printf("%8.3f\t",pop[i].f1);
	  	printf("%8.3f\t",roulette[i]);
	  	printf("%8.3f\t",pop[i].f1 + min);
	  	//printf("%f\n",min);
	  	printf("\n");
	  }

	// Dump sur fichier les valeurs de la roulette 0
	if (generation==0)
	{

	  f = fopen("MHwheelinit.dat", "w");

  	  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");
	  for(i=0;i<nPoints;i++)
	  {
		//edite les resultats
		fprintf(f,"%3d %8.3f %8.3f %8.3f \n",i+1, pop[i].f1, roulette[i], pop[i].f1 + min);
	  }
	  fclose(f);

	}

	  /* ------------------------------------------------------- */
	  /* Realise l'evolution generationnelle de la population */

	  for(i=0;i<nPoints/2;i++)
	  {
		  /* ------------------------------------------------------- */
		  /* selection de deux parents */

		  printf("\n = = = = = = = = = = = = = = SELECTION %2d %2d  = = = = = = = = = = = = = = \n", generation+1,i+1);
		  printf("\n");


		  tirage1 = rndreal(0.0,sommeFitness);
		  individu1=0;
		  while (roulette[individu1]<tirage1) individu1++;

		  tirage2 = rndreal(0.0,sommeFitness);
		  individu2=0;
		  while (roulette[individu2]<tirage2) individu2++;

		  printf("%8.3f \t %3d \t",tirage1, individu1+1);

		  for(j=0;j<lBit;j++){
		  	printf("%d", pop[individu1].bx[j]);
		  }

		  printf("\t");

		  for(j=0;j<lBit;j++){
		  	printf("%d", pop[individu1].bx2[j]);
		  }
		  printf("\n");

		  printf("%8.3f \t %3d \t",tirage2, individu2+1);

		  		  for(j=0;j<lBit;j++){
		  	printf("%d", pop[individu2].bx[j]);
		  }

		  printf("\t");

		  for(j=0;j<lBit;j++){
		  	printf("%d", pop[individu2].bx2[j]);
		  }

		  printf("\n\n");


		  /* ------------------------------------------------------- */
		  /* evolution */

		  printf("\n = = = = = = = = = = = = = = CROSSOVER %2d %2d  = = = = = = = = = = = = = = \n", generation+1,i+1);
		  printf("\n");

		  // crossover a un point cree deux enfants

		  cut = lBit;
		  proba = rndreal(0.0,1.0);
		  printf("\n Probabilité CROSSOVER = %f \n", proba);

		  if (proba <= probaCrossover)
			  {
				  cut=rnd(1,lBit-1);
			  }

		  for(j=0;j<cut;j++)
			  {
				  enfant1.bx[j] = pop[individu1].bx[j];
				  enfant1.bx2[j] = pop[individu1].bx2[j];

				  enfant2.bx[j] = pop[individu2].bx[j];
				  enfant2.bx2[j] = pop[individu2].bx2[j];
			  }
			  for(j=cut;j<lBit;j++)
			  {
				  enfant1.bx[j] = pop[individu2].bx[j];
				  enfant1.bx[j] = pop[individu2].bx2[j];

				  enfant2.bx[j] = pop[individu1].bx[j];
				  enfant2.bx[j] = pop[individu1].bx2[j];
			  }


		  printf("Cut = %3d \n",cut);
		  printf("%3d ",2*i+1);
		  for(j=0;j<cut;j++) {
		  	printf("%d", enfant1.bx[j]);
		  }
		  printf("|");

		  for(j=cut;j<lBit;j++) {
		  	printf("%d", enfant1.bx[j]);
		  }
		  printf("\t\t");

		   for(j=0;j<cut;j++) {
		  	printf("%d", enfant1.bx2[j]);
		  }
		  printf("|");

		  for(j=cut;j<lBit;j++) {
		  	printf("%d", enfant1.bx2[j]);
		  }

		  printf("\n\n");

		  printf("%3d ",2*i+2);
		  for(j=0;j<cut;j++){
		  	printf("%d", enfant2.bx[j]);
		  }
		  printf("|");
		  for(j=cut;j<lBit;j++){
		  	printf("%d", enfant2.bx[j]);
		  }
		  printf("\t\t");
		  for(j=0;j<cut;j++){
		  	printf("%d", enfant2.bx2[j]);
		  }
		  printf("|");
		  for(j=cut;j<lBit;j++){
		  	printf("%d", enfant2.bx2[j]);
		  }

		  printf("\n\n");

		  // Edition des resultats

		  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");


		  // enfant1 : decode la variable x et memorise les resultats	---
		  xPrim = 0; puis= 1;
		  for(j=lBit;j!=0;j--)
			  {  xPrim = xPrim + (long int)(enfant1.bx[j-1]) * puis;
				  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
				  puis = 2 * puis;
			  }

		  xPrim2 = 0; puis= 1;
		  for(j=lBit;j!=0;j--)
			  {  xPrim2 = xPrim2 + (long int)(enfant1.bx2[j-1]) * puis;
				  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
				  puis = 2 * puis;
			  }

		  enfant1.x = -10.0 + (double)(xPrim) * 20.0/(33554432.0 - 1.0);
 	      enfant1.x2 = -10.0 + (double)(xPrim2) * 20.0/(33554432.0 - 1.0);

		  enfant1.f1 =  pow((enfant1.x + 2 * enfant1.x2 - 7),2) + pow((2 * enfant1.x + enfant1.x2 - 5),2) ;

		  //edite les resultats
		  printf("%3d ",1);
		  for(j=0;j<lBit;j++) printf("%d",enfant1.bx[j]); printf("\t ");
		  for(j=0;j<lBit;j++) printf("%d",enfant1.bx2[j]); printf("\t");
		  printf("%3f \t %3f \t %3f\n",enfant1.x,enfant1.x2,enfant1.f1);
		  //  fprintf(f,"%4d %6.3f %6.3f\n",i, enfant1.x, enfant1.f1);


		  // enfant2 : decode la variable x et memorise les resultats	---
		  xPrim = 0; puis= 1;
		  for(j=lBit;j!=0;j--)
		  {  xPrim = xPrim + (long int)(enfant2.bx[j-1]) * puis;
			  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
			  puis = 2 * puis;
		  }
		  xPrim2 = 0; puis= 1;
		  for(j=lBit;j!=0;j--)
			  {  xPrim2 = xPrim2 + (long int)(enfant2.bx2[j-1]) * puis;
				  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
				  puis = 2 * puis;
			  }

		  enfant2.x = -10.0 + (double)(xPrim) * 20.0/(33554432.0 - 1.0);
 	      enfant2.x2 = -10.0 + (double)(xPrim2) * 20.0/(33554432.0 - 1.0);

		  enfant2.f1 =  pow((enfant2.x + 2 * enfant2.x2 - 7),2) + pow((2 * enfant2.x + enfant2.x2 - 5),2) ;

		  //edite les resultats
		  printf("%3d ",2);
		  for(j=0;j<lBit;j++) printf("%d",enfant2.bx[j]); printf("\t ");
		  for(j=0;j<lBit;j++) printf("%d",enfant2.bx2[j]); printf("\t ");
		  printf("%3f \t %3f \t %3f\n",enfant2.x,enfant2.x, enfant2.f1);
		  //  fprintf(f,"%4d %6.3f %6.3f\n",i, enfant2.x, enfant2.f1);


		  // Realise la mutation

		  printf("\n = = = = = = = = = = = = = = MUTATION %2d %2d  = = = = = = = = = = = = = = \n", generation+1,i+1);

		  // mutation sur enfant1
		  proba = rndreal(0.0,1.0);
		  printf("\n Probabilité Mutation = %f \n", proba);

		  if (proba <= probaMutation)
			  {

				  bit=rnd(0,lBit-1);

				  printf("Numéro de bit à changer lors de la mutation = %3d \n",bit);

				  printf("mutation -> %3d ",i+1);
				  for(j=0;j<lBit;j++) printf("%d",enfant1.bx[j]); printf("\t");
				  for(j=0;j<lBit;j++) printf("%d",enfant1.bx2[j]); printf("\n");

				  enfant1.bx[bit] = ((enfant1.bx[bit]+1)%2);
				  enfant1.bx2[bit] = ((enfant1.bx2[bit]+1)%2);

				  printf("%3d ",i+1);
				  for(j=0;j<lBit;j++) printf("%d",enfant1.bx[j]); printf("\t");
				  for(j=0;j<lBit;j++) printf("%d",enfant1.bx2[j]); printf("\n");

				  // redecode la variable x et memorise les resultats

				  xPrim = 0; puis= 1;
		   		  for(j=lBit;j!=0;j--){
		   		  	xPrim = xPrim + (long int)(enfant1.bx[j-1]) * puis;
		   		  	//printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
		   		  	puis = 2 * puis;
		   		  }
		   		  xPrim2 = 0; puis= 1;
		   		  for(j=lBit;j!=0;j--){
		   		  	xPrim2 = xPrim2 + (long int)(enfant1.bx2[j-1]) * puis;
		   		  	//printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
		   		  	puis = 2 * puis;
		   		  }
		   		  enfant1.x = -10.0 + (double)(xPrim) * 20.0/(33554432.0 - 1.0);
		   		  enfant1.x2 = -10.0 + (double)(xPrim2) * 20.0/(33554432.0 - 1.0);
		   		  enfant1.f1 =  pow((enfant1.x + 2 * enfant1.x2 - 7),2) + pow((2 * enfant1.x + enfant1.x2 - 5),2) ;

			  } // fin -- mutation sur enfant1

		  // mutation sur enfant2
		  proba = rndreal(0.0,1.0);
		  printf("\n Probabilité Mutation = %f \n", proba);

		  if (proba <= probaMutation)
		  {

			  bit=rnd(0,lBit-1);

			  printf("%3d Numéro de bit à changer lors de la mutation = \n",bit);

			  printf("%3d ",i+2);
			  for(j=0;j<lBit;j++) printf("%d",enfant2.bx[j]); printf("\n");
			  for(j=0;j<lBit;j++) printf("%d",enfant2.bx2[j]); printf("\n");

			  enfant2.bx[bit] = ((enfant2.bx[bit]+1)%2);
			  enfant2.bx2[bit] = ((enfant2.bx2[bit]+1)%2);

			  printf("mutation -> %3d ",i+2);
			  for(j=0;j<lBit;j++) printf("%d",enfant2.bx[j]); printf("\n");
			  for(j=0;j<lBit;j++) printf("%d",enfant2.bx2[j]); printf("\n");

			  // redecode la variable x et memorise les resultats
			  xPrim = 0; puis= 1;
			  for(j=lBit;j!=0;j--)
			  {  xPrim = xPrim + (long int)(enfant2.bx[j-1]) * puis;
				  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
				  puis = 2 * puis;
			  }

			  xPrim2 = 0; puis= 1;
			  for(j=lBit;j!=0;j--)
			  {  xPrim2 = xPrim2 + (long int)(enfant2.bx2[j-1]) * puis;
				  //printf(" %d %d %ld %ld \n", j, pop[i].bx[j-1], xPrim, puis);
				  puis = 2 * puis;
			  }

			  enfant2.x = -10.0 + (double)(xPrim) * 20.0/(33554432.0 - 1.0);
		   	  enfant2.x2 = -10.0 + (double)(xPrim2) * 20.0/(33554432.0 - 1.0);
		   	  enfant2.f1 =  pow((enfant2.x + 2 * enfant2.x2 - 7),2) + pow((2 * enfant2.x + enfant2.x2 - 5),2) ;

		  } // fin -- mutation sur enfant2

		  printf("\n");
		  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");

		  //edite les resultats
		  printf("%3d ",1);
		  for(j=0;j<lBit;j++) printf("%d",enfant1.bx[j]); printf("\t");
		  for(j=0;j<lBit;j++) printf("%d",enfant1.bx2[j]); printf("\t");
		  printf("%3f \t %3f  \t %3f\n",enfant1.x, enfant1.x2, enfant1.f1);
		  //  fprintf(f,"%4d %6.3f %6.3f\n",i, enfant1.x, enfant1.f1);

		  //edite les resultats
		  printf("%3d ",2);
		  for(j=0;j<lBit;j++) printf("%d",enfant2.bx[j]); printf("\t");
		  for(j=0;j<lBit;j++) printf("%d",enfant2.bx2[j]); printf("\t");
		  printf("%3f \t %3f \t %3f\n",enfant2.x, enfant2.x2, enfant2.f1);
		  //  fprintf(f,"%4d %6.3f %6.3f\n",i, enfant2.x, enfant2.f1);


		  printf("\n = = = = = = = = = = = = = = TOURNOI %2d %2d  = = = = = = = = = = = = = = \n", generation+1,i+1);

          printf(" parent 1 %3f parent 2 %3f",pop[individu1].f1 , pop[individu2].f1);
		  // Tournoi entre parents : garde le meilleur
		  if(pop[individu1].f1 < pop[individu2].f1)
		  {
			  // Sauvegarde best parent (le 1)
			  for(j=0;j<lBit;j++) popSelected[2*i].bx[j] = pop[individu1].bx[j];
			  for(j=0;j<lBit;j++) popSelected[2*i].bx2[j] = pop[individu1].bx2[j];
			  popSelected[2*i].x = pop[individu1].x;
			  popSelected[2*i].x2 = pop[individu1].x2;
			  popSelected[2*i].f1 = pop[individu1].f1;

			  //edite les resultats
			  printf("%3d ",1);
		  }
		  else
		  {
			  // Sauvegarde best parent (le 2)
			  for(j=0;j<lBit;j++) popSelected[2*i].bx[j] = pop[individu2].bx[j];
			  for(j=0;j<lBit;j++) popSelected[2*i].bx2[j] = pop[individu2].bx2[j];
			  popSelected[2*i].x = pop[individu2].x;
			  popSelected[2*i].x2 = pop[individu2].x2;
			  popSelected[2*i].f1 = pop[individu2].f1;

			  //edite les resultats
			  printf("%3d ",2);
		  }
		  for(j=0;j<lBit;j++) printf("%d",popSelected[2*i].bx[j]); printf("\t");
		  for(j=0;j<lBit;j++) printf("%d",popSelected[2*i].bx2[j]); printf("\t");
		  printf("%3f \t %3f \t %3f\n",popSelected[2*i].x, popSelected[2*i].x2, popSelected[2*i].f1);


          printf(" enfant 1 %3f enfant 2 %3f",	enfant1.f1 , enfant2.f1);
		  // Tournoi entre enfants : garde le meilleur
		  if(enfant1.f1 < enfant2.f1)
		  {
			  // Sauvegarde best enfant (le 1)
			  for(j=0;j<lBit;j++) popSelected[2*i+1].bx[j] = enfant1.bx[j];
			  for(j=0;j<lBit;j++) popSelected[2*i+1].bx2[j] = enfant1.bx2[j];
			  popSelected[2*i+1].x = enfant1.x;
			  popSelected[2*i+1].x2 = enfant1.x2;
			  popSelected[2*i+1].f1 = enfant1.f1;
			  printf("%3d ",1);
		  }
		  else
		  {
			  // Sauvegarde best enfant (le 2)
			  for(j=0;j<lBit;j++) popSelected[2*i+1].bx[j] = enfant2.bx[j];
			  for(j=0;j<lBit;j++) popSelected[2*i+1].bx2[j] = enfant2.bx2[j];
			  popSelected[2*i+1].x = enfant2.x;
			  popSelected[2*i+1].x2 = enfant2.x2;
			  popSelected[2*i+1].f1 = enfant2.f1;
			  printf("%3d ",2);
		  }
		  for(j=0;j<lBit;j++) printf("%d",popSelected[2*i+1].bx2[j]); printf("\t");
		  for(j=0;j<lBit;j++) printf("%d",popSelected[2*i+1].bx2[j]); printf("\t");
		  printf("%3f \t %3f \t %3f\n",popSelected[2*i+1].x, popSelected[2*i+1].x, popSelected[2*i+1].f1);


	  } // fin -- Realise l'evolution de parents 2 a 2 au regard de f1


	  // Met a jour la population : une nouvelle generation

	  for(i=0;i<nPoints;i++)
	  {
		  for(j=0;j<lBit;j++) pop[i].bx[j] = popSelected[i].bx[j];
		  for(j=0;j<lBit;j++) pop[i].bx2[j] = popSelected[i].bx2[j];
		  pop[i].x = popSelected[i].x;
		  pop[i].x2 = popSelected[i].x2;
		  pop[i].f1 = popSelected[i].f1;
	  }

	  // Edition des resultats

	  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");
	  for(i=0;i<nPoints;i++)
	  {
		  //edite les resultats
		  printf("%3d ",i+1);
		  for(j=0;j<lBit;j++) printf("%d",pop[i].bx[j]); printf("\t");
		  for(j=0;j<lBit;j++) printf("%d",pop[i].bx2[j]); printf("\t");
		  printf("%6.3f \t %6.3f \t %6.3f\n",pop[i].x,pop[i].x2,pop[i].f1);
		 // fprintf(f,"%4d %6.3f %6.3f\n",i, pop[i].x, pop[i].f1);
	  }

 	 printf("\n = = = = = = = = = = = = = = AVG FITNESS %2d %2d  = = = = = = = = = = = = = = \n", generation+1,i+1);

	 // Calcul du fitness moyen de la population courante
	  for(i=0;i<nPoints;i++)
	    fitnessAvg[generation]=fitnessAvg[generation]+pop[i].f1;
	  fitnessAvg[generation]=fitnessAvg[generation]/nPoints;

	 printf("AvgFitness = %6.3f \n", fitnessAvg[generation]);


}
	  printf("\n =========================== RESULTATS =========================== \n");

	  f = fopen("MHsop1avg.dat", "w");
      for (generation=0; generation<nGeneration; generation++)
	  {
	    printf(" %3d \t %6.3f ", generation+1, fitnessAvg[generation]);
        printf("\n");
		fprintf(f," %3d %6.3f \n", generation+1, fitnessAvg[generation]);
	  }
	  fclose(f);


	  f = fopen("MHsop1full.dat", "w");
	  for(x=-10;x<10;x=x+0.5){
	  	for(y=-10;y<10;y=y+0.5){
	      z= pow((x+2*y-7),2) + pow((2*x+y-5),2) ;
		  fprintf(f,"%4d %6.3f %6.3f %6.3f\n",i, x, y, z);
		}
	  }
	  fclose(f);


	  // Edition des resultats

	  f = fopen("MHsop1last.dat", "w");

	  printf("  i \t b1(x) \t\t\t\t b2(x) \t\t\t\t x1 \t x2 \t fx \n");
	  for(i=0;i<nPoints;i++)
	  {
		  //edite les resultats
		  printf("%3d ",i+1);
		  for(j=0;j<lBit;j++) printf("%d",pop[i].bx[j]); printf("\t");
		  	for(j=0;j<lBit;j++) printf("%d",pop[i].bx2[j]); printf("\t");
		  printf("%6.3f \t %6.3f \t %6.3f\n",pop[i].x,pop[i].x2,pop[i].f1);
		  fprintf(f,"%4d %6.3f %6.3f %6.3f\n",i, pop[i].x,pop[i].x2, pop[i].f1);
	  }
	  fclose(f);

	  /* ------------------------------------------------------- */

	  // Ouverture du shell et lancement de gnuplot
	  f = popen("gnuplot", "w");

	  // exécution de la commande gnuplot
	  fprintf(f, " set xrange [-10 : 10] \n");
	  fprintf(f, " set yrange [-10 : 10] \n");
	  fprintf(f, " set ticslevel 0 \n");
	  fprintf(f, " set zrange [0 : 600] \n");
	  fprintf(f, " set isosample 40 \n");

	  fprintf(f, " set title \"SOGA  |  SO-NLP  |  nPoints=%3d  nGeneration=%3d  Pc=%2.2f  Pm=%2.2f \" \n",nPoints, nGeneration, probaCrossover, probaMutation);
	  fprintf(f, " set xlabel \" x \" \n");
	  fprintf(f, " set ylabel \" y \" \n");
	  fprintf(f, " set zlabel \" f(x) \" \n");
	  fprintf(f, " splot \"MHsop1init.dat\" using 2:3:4 notitle w points ps 1\n");
	  fprintf(f, " replot \"MHsop1last.dat\" using 2:3:4 notitle w points ps 2\n");
	  fprintf(f, " replot \"MHsop1full.dat\" using 2:3:4 notitle w points ps 0\n");
	  fflush(f);
	  // terminer l'envoi de commandes et fermer gnuplot
	  sleep(10);
	  pclose(f);
	  /* ------------------------------------------------------- */

	  // Ouverture du shell et lancement de gnuplot
	  f = popen("gnuplot", "w");

	  // exécution de la commande gnuplot
	  fprintf(f, " set xrange [0 : %3d] \n", nGeneration);
	  fprintf(f, " set zrange [-10 : 10] \n");
	  fprintf(f, " set style line 1 lc rgb '#8b1a0e' pt 5 ps 2 lt 1 lw 1.5 # --- red\n");
	  fprintf(f, " set style line 12 lc rgb '#808080' lt 0 lw 0.5 \n");
	  fprintf(f, " set grid back ls 12 \n");
	  fprintf(f, " set title \"SOGA  |  SO-NLP  |  nPoints=%3d  nGeneration=%3d  Pc=%2.2f  Pm=%2.2f \" \n",nPoints, nGeneration, probaCrossover, probaMutation);
	  fprintf(f, " set xlabel \" generations \" \n");
	  fprintf(f, " set zlabel \" average fitness \" \n");
	  fprintf(f, " plot \"MHsop1avg.dat\" using 1:2 notitle w lines lt 1 lw 1 \n");
	  fprintf(f, " replot \"MHsop1avg.dat\" using 1:2 notitle w lp ls 1 \n");
	 // fprintf(f, " replot \"MHsop1avg.dat\" using 1:2 notitle w points pt 5 ps 2\n");
	  fflush(f);
	  // terminer l'envoi de commandes et fermer gnuplot
	  sleep(20);
	  pclose(f);

  }

/* ============================================================ */
