struct Individu
    bx::Array{Int64,1}
    x::Float64
    obj1::Float64
    obj2::Float64
    rank::Int
    crowding::Float64
end
function nsga()
    # Algorithms inputs
    nIndividus = 10
    nGenerations = 50
    crossoverProbability = 0.10
    mutationProbability = 0.10
    # definition de la variable et son domaine de variation
    x = 0.0
    xInf  = -5.0;
    xSup  =  5.0;
    delta = xSup - xInf
    precision = 3
    # Determine n
    n = log(delta * 10^precision)/(log(2))
    if !(trunc(n) == n)
        n = n+1
    end
    n = round(Int,trunc(n))
    # Generate n initial population of nIndividus
    tableIndividus = Individu[]
    for ind = 1:nIndividus
        bx = zeros(Int,n)
        for binIndice =1:n
            bx[binIndice] = rand(0:1)
        end
        # expression of x' (valeur en base 2)
        xprime = sum(bx[binIndice]*2^(binIndice-1) for binIndice= 1:n)
        x = xInf + xprime * (delta / (2^n -1))
        obj1 = objective1(x)
        obj2 = objective2(x)
        newIndividu = Individu(bx,x,obj1,obj2,0,0)
        push!(tableIndividus,newIndividu)
    end
    affichage(tableIndividus)
    #Boucle de Generations
    # for g = 1:nGenerations
    #     S1 = #selectionner les (n/2) meilleurs individus sur obj1
    #     S2 = #selectionner les (n/2) meilleurs individus sur obj2
    #     # schuffle
    #     # S = union(S1,S2)
    # end
end

function selection(indX1,indX2)
    if indX1[rank] < indX2[rank]
        # indX1 est choisi
    elseif indX1[rank] > indX2[rank]
        # indX2 est choisi
    else
        # return individu with the best
        # crowding(indX1,indX2)
        # return indX1[crowding] indX2[crowding]
        if indX1[crowding] > indX2[crowding]
            #return indX1
        elseif indX1[crowding] < indX2[crowding]
            #return indX2
        else
            # rand betwen
        end

    end
end

function mutation(x,position)
end

function crossover(x1,x2,cut)
end

function objective1(x)
    # Schaffer case
    return x^2
end

function objective2(x)
    # Schaffer case
    return (x-2)^2
end
function affichage(individus)
    n = length(individus)
    for i=1:n
        # println("individu $i")
        print(individus[1].bx);print("\t")
        print(individus[1].x);print("\t")
        print(individus[1].obj1);print("\t")
        print(individus[1].obj2);print("\t")
        print(individus[1].rank);print("\t")
        println(individus[1].crowding)
    end
end
