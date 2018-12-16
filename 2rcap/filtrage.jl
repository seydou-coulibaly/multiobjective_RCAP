function dominance(solution,indF1,indF2)
    # println("----------------------------------------------------------------------")
    # println("\n************************* \t Non dominated Points \t *************************\n")
    # on suppose  solution est deja bien trié suivant f1 grâce à la function lexicographically
    # yn est une copie de l'ens solution
    solution = lexicographically(solution,indF1)
    yn = copy(solution)
    i = 1
    while i <= length(yn[:,1])
        # print("Nombre de ligne = ")
        # println(length(yn[:,1]))

        j = 1
        while j <= length(yn[:,1])
            # println()
            # affichageMatrice(yn)
            # println()
            # print("\ni = $i\t")
            # print("j = $j\t")
            # println()
            # si i domine j dans yn
            if( (yn[i,indF1] <  yn[j,indF1] && yn[i,indF2] <  yn[j,indF2]) ||
                (yn[i,indF1] == yn[j,indF1] && yn[i,indF2] <  yn[j,indF2]) ||
                (yn[i,indF1] <  yn[j,indF1] && yn[i,indF2] == yn[j,indF2])
                )
                # à activer pour voir si i domine j
                # println("i = $i domine j = $j")
                # print(Int(yn[i,1]));print(" domine ");println(Int(yn[j,1]))
                # alors enlever j de yn
                yn = vcat(yn[1:j-1,:],yn[j+1:end,:])
                j = j-1
                if i > j
                    i = i-1
                end
            end
            j = j+1
        end
        #affichageMatrice(yn)
        i = i+1
    end
    return yn
end

function lexicographically(solution,indF1)
    # ranger par ordre croissant
    lexz1 = sortperm(solution[:,indF1])
    y = copy(solution)
    for i = 1:length(lexz1)
        y[i,:] = solution[lexz1[i],:]
    end
    return y
end
function affichageMatrice(matrice)
    n,m = size(matrice)
    for i = 1:n
        # print("i = $i")
        print("\t")
        for j= 1:m
            print(matrice[i,j])
            print("\t")
        end
        println()
    end
end
