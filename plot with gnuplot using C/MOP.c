/* ===========================================================
   Xavier Gandibleux
   MOMH
   2012
   =========================================================== */


/* Librairies a inclure ====================================== */

  #include <stdio.h>


/* Constantes ================================================ */

  #define interactif 0         /* 1 : oui / 0 : non */


/* =========================================================== */
/* Point d entree principal ================================== */

  int main(void)
  {
	  int i;

	  // definition de la variable et son domaine de variation
	  double x;
	  double xInf  = -4.0;
	  double xSup  =  4.0;

	  // definition du pas de calcul
	  int    step  = 200;
	  double xDelta;

	  // definition des fonctions
	  double f1;
	  double f2;

	  FILE * f;

    /* ------------------------------------------------------- */

	  f = fopen("MOMHmop1.dat", "w");

	  xDelta = (xSup-xInf)/step;

	  printf("   i      x     f1     f2\n");
	  for(i=0;i<step+1;i++)
	  {
		  x = xInf + (double)i * xDelta;
		  f1 = x*x;
		  f2 = (x-2)*(x-2);
		  printf("%4d %6.2f %6.2f %6.2f\n",i, x, f1, f2);
		  fprintf(f,"%4d %6.2f %6.2f %6.2f\n",i, x, f1, f2);
	  }
	  fclose(f);

	  /* ------------------------------------------------------- */

	  // Ouverture du shell et lancement de gnuplot
	  f = popen("gnuplot", "w");

	  // exécution de la commande gnuplot
    //fprintf(f, " set term dumb \n");
	  fprintf(f, " set xrange [0 : 4] \n");
	  fprintf(f, " set yrange [0 : 4] \n");
	  fprintf(f, " set title \"MOP 1: Schaffer\" \n");
	  fprintf(f, " set xlabel \" z1 \" \n");
	  fprintf(f, " set ylabel \" z2 \" \n");
	  fprintf(f, " plot \"Schaffer.dat\" using 3:4 notitle with lines\n");
	  fflush(f);
	  // terminer l'envoi de commandes et fermer gnuplot
	  sleep(60);
	  pclose(f);
  }

/* ============================================================ */
