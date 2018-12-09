function filteringYN(solution,indF1,indF2)
    # println("\n************************* \t Non dominated Points \t *************************\n")
    # on suppose  solution est deja bien trié suivant f1 grâce à la function lexicographically
    # yn est une copie de l'ens solution
    yn = copy(solution)
    i = 1
    while i <= length(yn[:,1])
        # print("Nombre de ligne = ")
        # println(length(yn[:,1]))

        j = 1
        while j <= length(yn[:,1])
            # si i domine j dans yn
            if( (yn[i,indF1] <  yn[j,indF1] && yn[i,indF2] <  yn[j,indF2]) ||
                (yn[i,indF1] == yn[j,indF1] && yn[i,indF2] <  yn[j,indF2]) ||
                (yn[i,indF1] <  yn[j,indF1] && yn[i,indF2] == yn[j,indF2])
                )
                # à activer pour voir si i domine j
                # println("i = $i domine j = $j")
                # alors enlever j de yn
                yn = vcat(yn[1:j-1,:],yn[j+1:end,:])
                j = j-1
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


# Pour le PB kim
function suportedPoints(yn,indF1,indF2)
    println("\n************************* \t Supported Points \t *************************\n")
    yn = lexicographically(yn,indF1)
    u = yn[1,:]; u = reshape(u,(1,indF2))  # extremal (Plus petite valeur suivant f1)
    S = copy(yn)
    yns  = zeros(0,indF2)
    ynn = zeros(0,indF2)
    # ajouter u dans yns
    yns = vcat(yns,u)
    # supprimer u de S
    S = S[2:end,:]
    w = S[end,:]; w = reshape(w,(1,indF2)) # lexopt suivant f2
    ind = 0
    while u != w
        # println(u)
        # println(w)
        # println(typeof(u))
        min =  BigInt(typemax(Int))
        # cherche un nouveau u dans S
        #print("taille de S = "); println(length(S[:,1]))
        for i = 1:length(S[:,1])
            #println("i = $i")
            # calculer pente des solutions (u et iem de S)
            if (min >= pente(u[1,indF1],u[1,indF2],S[i,indF1],S[i,indF2]))
                min = pente(u[1,indF1],u[1,indF2],S[i,indF1],S[i,indF2])
                ind = i
                #print("*************************   pente = ");print(pente(u[1,indF1],u[1,indF2],S[i,indF1],S[i,indF2]))
                #println("\tMis a jour min avec ind = $ind")
            end
        end
        u = S[ind,:];u = reshape(u,(1,indF2))
        # inserer ce u dans yns
        yns = vcat(yns,u)
        # supprimer ce u de S
        if ind == 1
            S = S[2:end,:]
        elseif ind == length(S[:,1])
            S = S[1:ind-1,:]
        else
            S = vcat(S[1:ind-1,:],S[ind+1:end,:])
        end
        #affichageMatrice(S)
        # supprimer de S tous les i dont son f1 est plus petit ou egale à f1 de u
        j = 1
        while j <= length(S[:,1])
            #println("j = $j")
            if u[1,indF1] >= S[j,indF1]
                ynn = vcat(ynn,reshape(S[j,:],(1,indF2)))
                if j == 1
                    S = S[2:end,:]
                elseif j == length(S[:,1])
                    S = S[1:j-1,:]
                else
                    S = vcat(S[1:j-1,:],S[j+1:end,:])
                end
                j = j-1
            end
            j = j+1
        end
    end
    return (yns,ynn)
end

function pente(xa,ya,xb,yb)
    return (yb-ya)/(xb-xa)
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
# yn = [1 8 ;
#       3 6 ;
#       3 7 ;
#       4 7 ;
#       2 5 ;
#       2 6 ;
#       4 4 ;
#       8 3 ;
#       1.5 7.5 ;
#       2.5 4.8 ;
#       2.5 4.1 ;
#       1.1 7]
# yn = lexicographically(yn,1)
# println()
# affichageMatrice(yn)
# yns,ynn = suportedPoints(yn,1,2)
# println("Supported")
# affichageMatrice(yns)
# println("non Supported")
# affichageMatrice(ynn)
