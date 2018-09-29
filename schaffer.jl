function feasibleoutcomeSet()
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

    # -------------------------------------------------------

    f = open("Schaffer.dat", "w");
    println("   i      x     f1     f2\n");
    for i = 0:step
        x = xInf + i * xDelta;
        f1 = x*x;
        f2 = (x-2)*(x-2);
        x = round(x,2)
        f1 = round(f1,2)
        f2 = round(f2,2)
        solution[i+1,1] = x
        solution[i+1,2] = f1
        solution[i+1,3] = f2

        println("$i \t $x \t $f1 \t $f2\n");
        write(f,"$i \t $x \t $f1 \t $f2\n");
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
