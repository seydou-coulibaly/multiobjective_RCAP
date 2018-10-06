function filteringYN(solution,indF1,indF2)
    println("\n************************* \t Non dominated Points \t *************************\n")
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
    u = yn[1,:]; u = reshape(u,(1,indF2))  # extremal (Plus petite valeur suivant f1)
    S = copy(yn)
    ys = zeros(0,indF2)
    # ajouter u dans ys
    ys = vcat(ys,u)
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
        # print("taille de S = "); println(length(S[:,1]))
        for i = 1:length(S[:,1])
            # println("i= $i")
            # calculer pente des solutions (u et iem de S)
            if (min >= pente(u[1,indF1],u[1,indF2],S[i,indF1],S[i,indF2]))
                min = pente(u[1,indF1],u[1,indF2],S[i,indF1],S[i,indF2])
                ind = i
                # println("Mis a jour min avec ind = $ind")
            end
        end
        u = S[ind,:];u = reshape(u,(1,indF2))
        # inserer ce u dans ys
        ys = vcat(ys,u)
        # supprimer ce u de S
        if ind == 1
            S = S[2:end,:]
        elseif ind == length(S[:,1])
            S = S[1:ind-1,:]
        else
            S = vcat(S[1:ind-1,:],S[ind+1:end,:])
        end
        # affichageMatrice(S)
    end
    return ys
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
