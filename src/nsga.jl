include("filtrage.jl")
Random.seed!(1)
mutable struct Individu
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
    encodage = log(delta * 10^precision)/(log(2))
    if !(trunc(encodage) == encodage)
        encodage = encodage+1
    end
    encodage = round(Int,trunc(encodage))
    # Generate nIndividus : initial population
    tableIndividus = Individu[]
    for ind = 1:nIndividus
        bx = zeros(Int,encodage)
        for binIndice =1:encodage
            bx[binIndice] = rand(0:1)
        end
        # expression of x' (valeur en base 2)
        xprime = sum(bx[binIndice]*2^(binIndice-1) for binIndice= 1:encodage)
        x = xInf + xprime * (delta / (2^encodage -1))
        obj1 = objective1(x)
        obj2 = objective2(x)
        newIndividu = Individu(bx,x,obj1,obj2,0,0)
        push!(tableIndividus,newIndividu)
    end
    affichage(tableIndividus)
    # Boucle de Generations
    for g = 1:1
        # assume n is pair
        n = length(tableIndividus)
        Q = n/2
        Q = round(Int,trunc(Q))
        S1 = Individu[]
        S2 = Individu[]
        # S1 = #selectionner les (n/2) meilleurs individus sur obj1
        # S2 = #selectionner les (n/2) meilleurs individus sur obj2
        tab = Float64[]
        for i=1:n
            tab = vcat(tab,tableIndividus[i].obj1)
        end
        lex = sortperm(tab)
        for i = 1:Q
            S1 = vcat(S1,tableIndividus[lex[i]])
        end
        for i=1:n
            tab[i] = tableIndividus[i].obj2
        end
        lex = sortperm(tab)
        for i = 1:Q
            S2 = vcat(S2,tableIndividus[lex[i]])
        end
        # println()
        # affichage(S1)
        # println()
        # affichage(S2)
        # println()
        # Schuffle entire population -------------------------------------------------
        for i=1:Q
            tableIndividus[i] = S1[i]
            tableIndividus[Q+i] = S2[i]
        end
        println()
        affichage(tableIndividus)
        # Ranking --------------------------------------------------------------------
        rng = 0
        indRg = 1
        tableRng = copy(tableIndividus)
        m = 0
        while rng != n
            # Extraction d'une matrice
            yn = zeros(length(tableRng),2)
            for i = 1:length(tableRng)
                yn[i,1] = tableRng[i].obj1
                yn[i,2] = tableRng[i].obj2
            end
            # compute filteringYN
            yn = lexicographically(yn,1)
            yn = filteringYN(yn,1,2)
            # println()
            # affichageMatrice(yn)
            yn = union(yn[:,1],yn[:,1])
            # Defining rank and upload tableRng
            for i = 1:length(yn)
                for j = 1:n
                    if tableIndividus[j].obj1 == yn[i]
                        tableIndividus[j].rank = indRg
                        rng = rng + 1
                    end
                end
                j = 1
                while j <= length(tableRng)
                    if tableRng[j].obj1 == yn[i]
                        # oublier la ligne j
                        deleteat!(tableRng,j)
                        j = j-1
                    end
                    j = j+1
                end
            end
            indRg = indRg + 1
        end
        println()
        affichage(tableIndividus)
        # Crowding --------------------------------------------------------------------
        
        # Apply genetic operators


    end
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

function mutation(x,position,probabilite)
    # generate rand()
    n = length(x)
    gen = rand(1:n)
    if gen <= probabilite
        # doing mutation operations
    end
end

function crossover(x1,x2,probabilite)
    # generate rand()
    n = length(x)
    generate = rand(1:n)
    cut = rand(1:n)
    if cut <= probabilite
        # doing crossover operations
    end
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
        print(individus[i].bx);print("\t")
        print(individus[i].x);print("\t")
        print(individus[i].obj1);print("\t")
        print(individus[i].obj2);print("\t")
        print(individus[i].rank);print("\t")
        print(individus[i].crowding);println()
    end
end
