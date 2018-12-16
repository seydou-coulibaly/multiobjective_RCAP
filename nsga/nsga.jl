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
    nIndividus = 100
    nGenerations = 50
    crossoverProbability = 0.50
    mutationProbability = 0.20
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
    println("Init population : ")
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
    for g = 1:nGenerations
        # assume n is pair
        n = length(tableIndividus)
        # # Divise into Q population -------------------------------------------------
        # println("Q population subdivision : ")
        # Q = n/2
        # Q = round(Int,trunc(Q))
        # S1 = Individu[]
        # S2 = Individu[]
        # # S1 = #selectionner les (n/2) meilleurs individus sur obj1
        # # S2 = #selectionner les (n/2) meilleurs individus sur obj2
        # tab = Float64[]
        # for i=1:n
        #     tab = vcat(tab,tableIndividus[i].obj1)
        # end
        # lex = sortperm(tab)
        # for i = 1:Q
        #     S1 = vcat(S1,tableIndividus[lex[i]])
        # end
        # for i=1:n
        #     tab[i] = tableIndividus[i].obj2
        # end
        # lex = sortperm(tab)
        # for i = 1:Q
        #     S2 = vcat(S2,tableIndividus[lex[i]])
        # end
        # # println()
        # # affichage(S1)
        # # println()
        # # affichage(S2)
        # # println()
        # # Schuffle entire population -------------------------------------------------
        # println("Schuffle : ")
        # tableIndividus = union(S1,S2)
        # for i=1:Q
        #     tableIndividus[i] = S1[i]
        #     tableIndividus[Q+i] = S2[i]
        # end
        # println()
        # affichage(tableIndividus)
        # Apply genetic operators --------------------------------------------------------------------
        println("Genetic operators : ")
        # O t ← evolution(P t ↓, P c ↓, P m ↓)
        evolution = Individu[]
        for nb=1:(n/2)
            # CROSSOVER
            # selection de deux parents
            p1 = rand(1:n)
            p2 = rand(1:n)
            if rand() <= crossoverProbability
                # println("\tyes")
                (f1,f2) = crossover(tableIndividus,p1,p2)
            else
                # print("\tNo")
                f1 = tableIndividus[p1].bx
                f2 = tableIndividus[p2].bx
            end

            # MUTATION
            if rand() <= mutationProbability
                f1 = mutation(f1)
            end
            if rand() <= mutationProbability
                f2 = mutation(f2)
            end
            # Deux fils f1 et f2 sont obtenus des parents p1 et p2

            # expression of x' (valeur en base 2)
            xprime1 = sum(f1[binIndice]*2^(binIndice-1) for binIndice= 1:encodage)
            xprime2 = sum(f2[binIndice]*2^(binIndice-1) for binIndice= 1:encodage)
            xf1 = xInf + xprime1 * (delta / (2^encodage -1))
            xf2 = xInf + xprime2 * (delta / (2^encodage -1))

            f1Obj1 = objective1(xf1)
            f1Obj2 = objective2(xf1)

            f2Obj1 = objective1(xf2)
            f2Obj2 = objective2(xf2)
            fils1 = Individu(f1,xf1,f1Obj1,f1Obj2,0,0)
            fils2 = Individu(f2,xf2,f2Obj1,f2Obj2,0,0)
            push!(evolution,fils1)
            push!(evolution,fils2)
        end
        affichage(evolution)

        # Elitims --------------------------------------------------------------------

        println("Elitims")

        combinedPopulation = union(tableIndividus,evolution)
        affichage(combinedPopulation)
        # Ranking --------------------------------------------------------------------
        println("\tRanking : ")
        populationSize = length(combinedPopulation)
        rng = 0
        indRg = 1
        tableRng = copy(combinedPopulation)
        m = 0
        while rng != populationSize
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
            # eleminer les doublons dans yn
            yn = union(yn[:,1],yn[:,1])
            # Defining rank and upload tableRng
            for i = 1:length(yn)
                for j = 1:populationSize
                    if combinedPopulation[j].obj1 == yn[i]
                        combinedPopulation[j].rank = indRg
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
        affichage(combinedPopulation)
        # indRg vaut indRg-1
        # Crowding --------------------------------------------------------------------
        # println("Crowding : ")
        # for i=1:populationSize
        #     combinedPopulation[i].crowding = 0
        # end
        # for i=1:(indRg-1)
        #     I = zeros(0,3)
        #     for j=1:length(combinedPopulation)
        #         if combinedPopulation[j].rank == i
        #             I = vcat(I,reshape([combinedPopulation[j].x,combinedPopulation[j].obj1,combinedPopulation[j].obj2],(1,3)))
        #         end
        #     end
        #     # pour chaque objective
        #     for j=1:2
        #         # println("Sort suivant la fonction objective $j")
        #         # sort la matrice suivant la case de la fonction objective
        #         I = lexicographically(I,(j+1))
        #         affichageMatrice(I)
        #         println()
        #         print
        #         # fixer le crowding des extrêmes à l'infini
        #         for k = 1:length(combinedPopulation)
        #             if combinedPopulation[k].x == I[1,1] || combinedPopulation[k].x == I[end,1]
        #                 combinedPopulation[k].crowding  = Inf
        #                 println("update $k inf")
        #             end
        #         end
        #         # calculer les autres crowding
        #         for k= 2:length(I[:,1])-1
        #             println("-----")
        #             if combinedPopulation[k].crowding != Inf
        #                 combinedPopulation[k].crowding = combinedPopulation[k].crowding + (I[k+1,(j+1)]-I[k,(j+1)])/(maximum(I[:,(j+1)])-minimum(I[:,(j+1)]))
        #                 println(combinedPopulation[k].crowding)
        #                 println("update $k")
        #             end
        #             println("-----")
        #
        #         end
        #     end
        #     # println()
        # end
        # println()
        # affichage(combinedPopulation)
        println("Generations $g")
        tab = Int[]
        for i=1:populationSize
            tab = vcat(tab,combinedPopulation[i].rank)
        end
        lex = sortperm(tab)
        for i = 1:n
            tableIndividus[i] = combinedPopulation[lex[i]]
        end

        affichage(tableIndividus)




        # Affichage de la generation --------------------------------------------------------------------


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

function mutation(f1)
    n = length(f1)
    oneBit = rand(1:n)
    f1[oneBit] = (f1[oneBit]+1)%2
    return f1
end

function crossover(tableIndividus,p1,p2)
    n = length(tableIndividus)
    # println("n = $n")
    encodage = length(tableIndividus[1].bx)
    cut = rand(1:encodage-1)
    # println("cut = $cut")
    # println("encodage = $encodage")
    f1 = zeros(Int,encodage)
    f2 = zeros(Int,encodage)
    for i=1:cut
        f1[i] = tableIndividus[p1].bx[i]
        f2[i] = tableIndividus[p2].bx[i]
    end
    for i=cut+1:encodage
        f1[i] = tableIndividus[p2].bx[i]
        f2[i] = tableIndividus[p1].bx[i]
    end
    return (f1,f2)
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
function ranking(population)
    println("\tRanking : ")
    populationSize = length(population)
    rng = 0
    indRg = 1
    tableRng = copy(population)
    m = 0
    while rng != populationSize
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
        # eleminer les doublons dans yn
        yn = union(yn[:,1],yn[:,1])
        # Defining rank and upload tableRng
        for i = 1:length(yn)
            for j = 1:populationSize
                if population[j].obj1 == yn[i]
                    population[j].rank = indRg
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
    affichage(population)
end
