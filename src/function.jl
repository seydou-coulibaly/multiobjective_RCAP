# include des fonction de filtrage
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
    println("\nFin de la fonction")

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

    yns,ynn = suportedPoints(yn,indF1,indF2)
    print("\t");print(length(yns[:,1]));println(" points found :\n")
    affichageMatrice(yns)

    print(length(yn[:,1]));println(" non-dominated points\n")
    print(length(yns[:,1]));println(" Supported points\n")
    print(length(ynn[:,1]));println(" Non-Supported points\n")

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
    f = open("kimyns.dat", "w");
    for i = 1:length(yns[:,1])
        x1  = yns[i,indV1]
        x2  = yns[i,indV2]
        f1  = yns[i,indF1]
        f2  = yns[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);
    #-----------------------------------------------------------------------------------------

    println("\nFin de la fonction")
end

function cantileverProblem()
    println("-------------------------------------------------------------------")
    println("\t \t**** \t  Cantilever's problem \t *****\t \t")
    println("-------------------------------------------------------------------")
    # definition de la variable et son domaine de variation
    l = 0.0
    d = 0.0
    delta = 0
    # definition du pas de calcul
    step  = 10000;

    P = 1
    E = 207
    Sy = 300
    rho = 7800
    deltaMax = 5
    cond = 1

    # solutions
    solution = zeros(step,4)
    indV1 = 1
    indV2 = 2
    indF1 = 3
    indF2 = 4
    # -------------------------------------------------------

    # generer step solutions
    f = open("dat/cantilever.dat", "w");
    for i = 1:step
        #println()
        cond = 0
        while cond == 0
            # generer d
            d = rand(Uniform(10, 50))
            # generer l
            l = rand(Uniform(200, 1000))

            l = round(l,3)
            d = round(d,3)
            rhoMax = (32 * P * l)/(pi * d^3)
            # delta
            delta = (64 * P * l^3)/(3 * E * pi * d^4)
            rhoMax = round(rhoMax,3)
            delta = round(delta,3)


            if rhoMax <= Sy && delta <= deltaMax
                cond = 1
            end

        end
        # definition des fonctions
        f1 = (rho * pi * (d*0.001)^2 * (l*0.001)) / 4
        f2 = delta

        f1 = round(f1,3)
        f2 = round(f2,3)
         # println("$i \t $d  \t $l \t $f1 \t $f2\n");
         write(f,"$i \t $d \t $l  \t $f1 \t $f2\n");
         solution[i,indV1] = d
         solution[i,indV2] = l
         solution[i,indF1] = f1
         solution[i,indF2] = f2
    end
    close(f);
    solution = lexicographically(solution,indF1)
    # affichageMatrice(solution)
    yn = filteringYN(solution,indF1,indF2)
    print("\t");print(length(yn[:,1]));println(" points found :\n")
    #affichageMatrice(yn)
    yns,ynn = suportedPoints(yn,indF1,indF2)
    print("\t");print(length(yns[:,1]));println(" points found :\n")
    affichageMatrice(yns)
    #
    println("\n$step points generated : \n")
    print(length(yn[:,1]));println(" non-dominated points\n")
    print(length(yns[:,1]));println(" Supported points\n")
    print(length(ynn[:,1]));println(" Non-Supported points\n")
    #
    #-----------------------------------------------------------------------------------------
    # Enregistrement dans fichier
    # println(" Graphique : ")
    f = open("dat/cantileverYN.dat", "w");
    for i = 1:length(yn[:,1])
        x1  = yn[i,indV1]
        x2  = yn[i,indV2]
        f1  = yn[i,indF1]
        f2  = yn[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);
    f = open("dat/cantileverns.dat", "w");
    for i = 1:length(yns[:,1])
        x1  = yns[i,indV1]
        x2  = yns[i,indV2]
        f1  = yns[i,indF1]
        f2  = yns[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);

    #--------------------------------------------------------------------------------------------------
    # Bound sets

    idealPoint = [yn[1,indF1],yn[length(yn[:,1]),indF2]]
    antiIdealPoint = [maximum(solution[:,indF1]),maximum(solution[:,indF2])]
    nadirPoint = [yn[length(yn[:,1]),indF1],yn[1,indF2]]
    print("Point ideal : ");println(idealPoint)
    print("Point nadir : ");println(nadirPoint)
    print("Point anti-ideal : ");println(antiIdealPoint)

    nbBorneSup = (length(yns[:,1])-1)
    borneSup = zeros(nbBorneSup,2)
    for i = 1:nbBorneSup
        borneSup[i,1] = yns[i+1,indF1]
        borneSup[i,2] = yns[i,indF2]
    end
    println("\nBorne sup :")
    affichageMatrice(borneSup)


    #-----------------------------------------------------------------------------------------*
    # Graphique with pyplot
    fig, ax = subplots()
    ax[:plot](solution[:,indF1],solution[:,indF2],linestyle="dotted",linewidth=0,marker=".",markersize=1,color="black")
    ax[:plot](ynn[:,indF1],ynn[:,indF2],linestyle="-.",linewidth=0,marker="o",markersize=4,color="green",label="non Supported point")
    ax[:plot](yns[:,indF1],yns[:,indF2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="red",label="Supported points")
    ax[:plot](idealPoint[1],idealPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="b",label="ideal point")
    ax[:plot](nadirPoint[1],nadirPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="b",label="nadir point")
    ax[:plot](antiIdealPoint[1],antiIdealPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="y",label="anti-ideal point")

    ax[:plot](borneSup[:,1],borneSup[:,2],linestyle="-.",linewidth=0,marker="o",markersize=5,color="orange", label="upper bound")
    #legend()
    xlabel("z1 : weight (kg) ");
    ylabel("z2 : deflection (mm) ");
    title("cantilever design problem (Objective space)");

    #-----------------------------------------------------------------------------------------

    println("\n *** Fin de la function ***")

end

function gearTrain()
    println("-------------------------------------------------------------------")
    println("\t \t**** \t  Gear Train \t *****\t \t")
    println("-------------------------------------------------------------------")
    # definition de la variable et son domaine de variation
    t1 = t2 = t3 = t4 = 0.0
    # definition du pas de calcul
    step  = 10000;

    f1 = f2 = 0.0

    # solutions
    solution = zeros(step,6)
    indV1 = 1
    indV2 = 2
    indV3 = 3
    indV4 = 4
    indF1 = 5
    indF2 = 6
    # -------------------------------------------------------

    # generer step solutions
    f = open("dat/gearTrain.dat", "w");
    for i = 1:step
        # println(" i = $i")
        cond = 0
        j = 1
        while cond == 0

            #println("tentative : $j")
            # generer les ti
            t1 = rand(12:30)
            t2 = rand(12:60)
            t3 = rand(12:17)
            t4 = rand(20:60)
            # print("t1 = $t1\t t2 = $t2 , \t t3 = $t3, \t t4= $t4")
            # s'assurer que c'est des entiers
            # Conditions
            # definition des fonctions
            f1 = abs(6.931 - ((t2*t4) / (t1*t3)))
            f2 = max(t1,t2,t3,t4)

            f1 = round(f1,3)
            f2 = round(f2,3)
            # println("\tf1 = $f1")

            if f1/6.931 <= 0.5
                cond = 1
                # println("cond1 active")
            end
            j = j+1
        end
         # println("$i \t $t1 \t $t2 \t $t3 \t $t4  \t $f1 \t $f2\n");
         write(f,"$i \t $t1 \t $t2 \t $t3 \t $t4  \t $f1 \t $f2\n");
         solution[i,indV1] = t1
         solution[i,indV2] = t2
         solution[i,indV3] = t3
         solution[i,indV4] = t4
         solution[i,indF1] = f1
         solution[i,indF2] = f2
    end
    close(f);
    solution = lexicographically(solution,indF1)
    # affichageMatrice(solution)
    yn = filteringYN(solution,indF1,indF2)
    print("\t");print(length(yn[:,1]));println(" points found :\n")
    affichageMatrice(yn)
    yns,ynn = suportedPoints(yn,indF1,indF2)
    print("\t");print(length(yns[:,1]));println(" points found :\n")
    affichageMatrice(yns)
    #
    println("\n$step points generated : \n")
    print(length(yn[:,1]));println(" non-dominated points\n")
    print(length(yns[:,1]));println(" Supported points\n")
    print(length(ynn[:,1]));println(" Non-Supported points\n")
    #-----------------------------------------------------------------------------------------
    # Enregistrement dans fichier
    # println(" Graphique : ")
    f = open("dat/gearYN.dat", "w");
    for i = 1:length(yn[:,1])
        x1  = yn[i,indV1]
        x2  = yn[i,indV2]
        f1  = yn[i,indF1]
        f2  = yn[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);
    f = open("dat/gear.dat", "w");
    for i = 1:length(yns[:,1])
        x1  = yns[i,indV1]
        x2  = yns[i,indV2]
        f1  = yns[i,indF1]
        f2  = yns[i,indF2]
        write(f,"$i \t $x1 \t $x2 \t $f1 \t $f2\n");
    end
    close(f);


    #--------------------------------------------------------------------------------------------------
    # Bound sets

    idealPoint = [yn[1,indF1],yn[length(yn[:,1]),indF2]]
    antiIdealPoint = [maximum(solution[:,indF1]),maximum(solution[:,indF2])]
    nadirPoint = [yn[length(yn[:,1]),indF1],yn[1,indF2]]
    print("Point ideal : ");println(idealPoint)
    print("Point nadir : ");println(nadirPoint)
    print("Point anti-ideal : ");println(antiIdealPoint)

    nbBorneSup = (length(yns[:,1])-1)
    borneSup = zeros(nbBorneSup,2)
    for i = 1:nbBorneSup
        borneSup[i,1] = yns[i+1,indF1]
        borneSup[i,2] = yns[i,indF2]
    end
    println("\nBorne sup :")
    affichageMatrice(borneSup)


    #-----------------------------------------------------------------------------------------
    # Graphique with pyplot
    fig, ax = subplots()
    ax[:plot](solution[:,indF1],solution[:,indF2],linestyle="dotted",linewidth=0,marker=".",markersize=1,color="black")
    ax[:plot](ynn[:,indF1],ynn[:,indF2],linestyle="-.",linewidth=0,marker="o",markersize=4,color="green",label="non Supported point")
    ax[:plot](yns[:,indF1],yns[:,indF2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="red",label="Supported points")
    ax[:plot](idealPoint[1],idealPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="b",label="ideal point")
    ax[:plot](nadirPoint[1],nadirPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="b",label="nadir point")
    ax[:plot](antiIdealPoint[1],antiIdealPoint[2],linestyle="-.",linewidth=1,marker="o",markersize=5,color="y",label="anti-ideal point")

    ax[:plot](borneSup[:,1],borneSup[:,2],linestyle="-.",linewidth=0,marker="o",markersize=5,color="orange", label="upper bound")
    #legend()

    xlabel("z1 : error ");
    ylabel("z2 : maximum diametre (cm) ");
    title("Gear objective (Objective space)");

    #-----------------------------------------------------------------------------------------

    println("\n *** Fin de la function ***")
end
