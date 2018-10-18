  #include <stdio.h>
  int main(void)
  {

    FILE * f;
	  // Ouverture du shell et lancement de gnuplot
	  f = popen("gnuplot", "w");

	  // exécution de la commande gnuplot
    //fprintf(f, " set term dumb \n");
	  fprintf(f, " set xrange [0 : 10] \n");
	  fprintf(f, " set yrange [0 : 10] \n");
	  fprintf(f, " set title \"MOP 1: Schaffer\" \n");
	  fprintf(f, " set xlabel \" z1 \" \n");
	  fprintf(f, " set ylabel \" z2 \" \n");
	  fprintf(f, " plot \"Schaffer.dat\" using 3:4 notitle with lines lt -1 linewidth 2\n");
    fprintf(f, " replot \"SchafferYN.dat\" using 3:4 notitle with lines lt rgb \"red\" \n");
	  fflush(f);
	  // terminer l'envoi de commandes et fermer gnuplot
	  sleep(60);
	  pclose(f);
  }
