function feasibleoutcomeSet()
    # definition de la variable et son domaine de variation
    x1 = 0.0
    x2 = 0.0
    x1Inf = x2Inf = -3.0;
    x1Sup = x2Sup =  3.0;

    # definition du pas de calcul
    step  = 200;
    xDelta = (x1Sup-x1Inf)/step;

    # definition des fonctions
    f1 = f2 = 0.0

    # solutions
    solution = zeros(step+1,4)

    # -------------------------------------------------------

    f = open("kim.dat", "w");
    println("   i      x     f1     f2\n");
    k = 0
    for i = 0:step
        for j = 0:step
            x1 = x1Inf + i * xDelta;
            x2 = x2Inf + j * xDelta;
            f1 = -(3*(1-x1)^2 * exp(-x1^2-(x2+1)^2)-10*(x1/5.0 - x1^3-x2^5)*exp(-x1^2-x2^2)-3*exp(-(x1+2)^2-x2^2) + 0.5*(2*x1+x2));
            f2 = -(3*(1+x2)^2*exp(-x2^2-(1-x1)^2)-10*(-x2/5.0+x2^3+x1^5)*exp(-x1^2-x2^2)-3*exp(-2*(2-x2)^2-x1^2));

            x1 = round(x1,2)
            x2 = round(x2,2)
            f1 = round(f1,6)
            f2 = round(f2,6)

            solution[i+1,1] = x1
            solution[i+1,2] = x2
            solution[i+1,3] = f1
            solution[i+1,4] = f2

            println("$k \t $x1 \t $x2 \t $f1 \t $f2\n");
            write(f,"$k \t $x1 \t $x2 \t $f1 \t $f2\n");
            k = k+1
        end
    end
    close(f);
    yn = filteringNondominated(solution)
    println("--------------------------------------------------------------------")
    print(length(yn[:,1]))
    println(" non-dominated points : ")
    # println(yn)
    affichageMatrice(yn)
    println("Fin du programme")


end

function affichageMatrice(matrice)
    n,m = size(matrice)
    for i = 1:n
        print(i)
        print("\t")
        for j= 1:m
            print(matrice[i,j])
            print("\t")
        end
        println()
    end
end

function filteringNondominated(solution)
    n = length(solution[:,1])
    yd = Int[]
    yn = Int[]
    for i = 1:n
        for j = 1:n
            # si xi domine xj alors enlever xj de yn
            if((solution[i,2] < solution[j,2] && solution[i,3] < solution[j,3]) ||
                (solution[i,2] == solution[j,2] && solution[i,3] < solution[j,3]) ||
                (solution[i,2] < solution[j,2] && solution[i,3] == solution[j,3])
                )
                push!(yd,j)
            end
        end
    end
    yd = unique(yd)
    # print("dominated points : taille = ")
    # println(length(yd))
    # println(yd)
    for i = 1:n
        if !in(i,yd)
            push!(yn,i)
        end
    end
    yn = solution[yn[1:end],:]
    return yn
end
feasibleoutcomeSet()
