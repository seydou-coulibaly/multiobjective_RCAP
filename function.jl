using PyPlot
using Distributions
include("filtrage.jl")
function schafferFunction()
    println("-------------------------------------------------------------------")
    println("\t \t**** \t  Schaffer's function \t *****\t \t")
    println("-------------------------------------------------------------------")
    # definition de la variable et son domaine de variation
    x = 0.0
    xInf  = -4.0;
    xSup  =  4.0;

    # definition du pas de calcul
    step  = 200;
    xDelta = (xSup-xInf)/step;;

    # definition des fonctions
    f1 = f2 = 0.0

    # solutions
    solution = zeros(step+1,3)
    indV1 = 1
    indF1 = 2
    indF2 = 3

    # -------------------------------------------------------

    f = open("Schaffer.dat", "w");
    # println("   i      x     f1     f2\n");
    for i = 0:step
        x = xInf + i * xDelta;
        f1 = x^2;
        f2 = (x-2)^2;
        x = round(x,2)
        f1 = round(f1,2)
        f2 = round(f2,2)
        solution[i+1,1] = x
        solution[i+1,indF1] = f1
        solution[i+1,indF2] = f2

        # println("$i \t $x \t $f1 \t $f2\n");
        write(f,"$i \t $x \t $f1 \t $f2\n");
    end
    close(f);
    solution = lexicographically(solution,indF1)
    println("\tx\tf1\tf2")
    affichageMatrice(solution)
    yn = filteringYN(solution,indF1,indF2)
    print(length(yn[:,1]))
    print("\t");print(length(yn[:,1]));println(" points found :\n")
    affichageMatrice(yn)
    # println(" Graphique : ")
    # f = open("SchafferYN.dat", "w");
    # for i = 1:length(yn[:,1])
    #     x  = yn[i,indV1]
    #     f1 = yn[i,indF1]
    #     f2 = yn[i,indF2]
    #     write(f,"$i \t $x \t $f1 \t $f2\n");
    # end
    # close(f);
    # ylabel('F2')
    # ylabel('F1')
    # plot(solution[:,indF1],solution[:,indF2],color="red",linewidth=2.0)
    println("\nFin du programme")

end

function kimFunction()
    println("-------------------------------------------------------------------")
    println("\t \t**** \t  Kim's function \t *****\t \t")
    println("-------------------------------------------------------------------")
    # definition de la variable et son domaine de variation
    x1 = 0.0
    x2 = 0.0
    x1Inf = x2Inf = -3.0;
    x1Sup = x2Sup =  3.0;

    # definition du pas de calcul
    step  = 10000;
    xDelta = (x1Sup-x1Inf)/step;

    # definition des fonctions
    f1 = f2 = 0.0

    # solutions
    solution = zeros(step,4)
    indV1 = 1
    indV2 = 2
    indF1 = 3
    indF2 = 4
    # -------------------------------------------------------

    f = open("kim.dat", "w");
    # println("   i      x     f1     f2\n");
    for i = 1:step
        x1 = x1Inf + i * xDelta;
        #x2 = x2Inf + j * xDelta;
        #x1 = rand()
        x1 = rand(Uniform(-3, 3))
        x2 = rand(Uniform(-3, 3))
        f1 = -(3*(1-x1)^2 * exp(-x1^2-(x2+1)^2)-10*(x1/5.0 - x1^3-x2^5)*exp(-x1^2-x2^2)-3*exp(-(x1+2)^2-x2^2) + 0.5*(2*x1+x2));
        f2 = -(3*(1+x2)^2*exp(-x2^2-(1-x1)^2)-10*(-x2/5.0+x2^3+x1^5)*exp(-x1^2-x2^2)-3*exp(-2*(2-x2)^2-x1^2));
        x1 = round(x1,2)
        x2 = round(x2,2)
        f1 = round(f1,6)
        f2 = round(f2,6)

        # println("$k \t $x1 \t $x2 \t $f1 \t $f2\n");
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
        solution[i,indV1] = x1
        solution[i,indV2] = x2
        solution[i,indF1] = f1
        solution[i,indF2] = f2

    end
    close(f);
    solution = lexicographically(solution,indF1)
    println("\tx1\tx2\tf1\t\tf2")
    affichageMatrice(solution)
    yn = filteringYN(solution,indF1,indF2)
    print("\t");print(length(yn[:,1]));println(" points found :\n")
    affichageMatrice(yn)

    ys = suportedPoints(yn,indF1,indF2)
    print("\t");print(length(ys[:,1]));println(" points found :\n")
    affichageMatrice(ys)

    print(length(yn[:,1]));println(" non-dominated points\n")
    print(length(ys[:,1]));println(" Supported points\n")

    #-----------------------------------------------------------------------------------------
    # println(" Graphique : ")
    f = open("kimYN.dat", "w");
    for i = 1:length(yn[:,1])
        x1  = yn[i,indV1]
        x2  = yn[i,indV2]
        f1  = yn[i,indF1]
        f2  = yn[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);
    f = open("kimYS.dat", "w");
    for i = 1:length(ys[:,1])
        x1  = ys[i,indV1]
        x2  = ys[i,indV2]
        f1  = ys[i,indF1]
        f2  = ys[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);
    #-----------------------------------------------------------------------------------------

    println("\nFin du programme")
end
