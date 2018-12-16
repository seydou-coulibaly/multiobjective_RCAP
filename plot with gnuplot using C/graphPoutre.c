#include <stdio.h>
int main(void)
{

  FILE * f;
  // Ouverture du shell et lancement de gnuplot
  f = popen("gnuplot", "w");

  // exécution de la commande gnuplot
  //fprintf(f, " set term dumb \n");
  fprintf(f, " set xrange [0 : 16] \n");
  fprintf(f, " set yrange [0 : 5] \n");

  fprintf(f, " set title \"cantilever design problem (Objective space)\" \n");
  fprintf(f, " set xlabel \" z1 : weight (kg) \" \n");
  fprintf(f, " set ylabel \" z2 : deflection (mm) \" \n");

  // fprintf(f, " set xrange [15 : 50] \n");
  // fprintf(f, " set yrange [200 : 1000] \n");

  // fprintf(f, " set title \"cantilever design problem (Decision space)\" \n");
  // fprintf(f, " set xlabel \" d : diametre (mm) \" \n");
  // fprintf(f, " set ylabel \" l : longueur (mm) \" \n");

  //fprintf(f, " plot \"../dat/cantilever.dat\" using 2:3 notitle with dots lt rgb \"red\" \n");


  fprintf(f, " plot \"../dat/cantilever.dat\" using 4:5 notitle with dots lt -1 linewidth 2\n");
  fprintf(f, " replot \"../dat/cantileverns.dat\" using 4:5 notitle with points lt rgb \"green\" \n");
  fprintf(f, " replot \"../dat/cantileverYN.dat\" using 4:5 notitle with points lt rgb \"red\" \n");
  //fprintf(f, " replot \"kimyns.dat\" using 4:5 notitle with dots lt rgb \"red\" \n");
  fflush(f);
  // terminer l'envoi de commandes et fermer gnuplot
  sleep(60);
  pclose(f);
}
