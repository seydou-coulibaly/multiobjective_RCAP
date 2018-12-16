include("filtrage.jl")
Random.seed!(1)
c1 = [13 14  7 2 11
      5  10 11 7 10
      7 19 9 16 19
      3 19 10 0 6
      12 9 2 4 15]
c2 = [ 1 13 15 18 3
       0 3 17 8 6
       9 5 8 0 4
       18 19 3 19 7
       2 3 19 12 15]
w = [1 2 3 2 1
     3 2 1 2 3
     3 3 3 3 3
     4 1 4 1 4
     1 5 1 5 1]
b = 11
(n,n) = size(c1)

mutable struct Individu
    id::Array{Int,1}
    solution::Array{Array{Int,1},1}
    obj1::Array{Float64,1}
    obj2::Array{Float64,1}
    rank::Array{Int,1}
    crowding::Array{Float64,1}
end
function nsga2()
    # Algorithms inputs
    popsize = 1000
    nGenerations = 20
    Pc = 0.70
    Pm = 0.20
    # Generate nIndividus : initial population --------------------------------------------------------------------------------------
    println()
    println("**************\t INITIALISATION OF POPULATION \t**************")
    println()
    # println("Identifiant \t Encodage-solution \t Obj1 \t Obj2 \t Rank \t Crowding")
    population = Individu([],[],[],[],[],[])
    for ind = 1:popsize
         individu = Random.shuffle(Vector(1:n))
         objective_1 = evalObjective(individu,c1)
         objective_2 = evalObjective(individu,c2)
         add(population,ind,individu,objective_1,objective_2,0,0)
    end
    affichage(population)
    # Ranking and crowding  ------------------------------------------------------------------------------------------------------------
    # println()
    ranking(population)
    # affichage(population)
    println()
    crowding(population)
    # affichage(population)
    println("#### Ranking ####")
    println("#### Crowding ####")
    # Boucle de Generations ------------------------------------------------------------------------------------------------------------
    for g = 1:nGenerations
        println()
        println("******* Generation $g ***********")
        Offspring = Individu([],[],[],[],[],[])
        indOffspring = 1
        # selection-------------------------------------------------------------
        matingPool = selection(population,(popsize/2))
        # affichage(matingPool)
        println()
        println("#### Selection(matingPool created) ####")
        # crossover and mutation -----------------------------------------------
        println("#### Genetic operators (CROSSOVER and MUTATION) ####")
        # nbCrossover= round(Int,trunc(length(matingPool.id)/2))
        numberInmatingPool= length(matingPool.id)
        nbCrossover = numberInmatingPool
        # println()
        for nb = 1:nbCrossover
            # println("Iteration $nb")
            # select 2 parents in matingPool to cross
            # println("$nb")
            parent1 = rand(1:numberInmatingPool)
            parent2 = rand(1:numberInmatingPool)
            while parent1 == parent2 && numberInmatingPool >= 2
                parent2 = rand(1:numberInmatingPool)
            end
            # print("\tp1 : ");print(matingPool.solution[parent1]);print("\tp2 : ");print(matingPool.solution[parent2])
            if rand() <= Pc
                (f1,f2) = crossover(matingPool.solution[parent1],matingPool.solution[parent2])
            else
                f1 = matingPool.solution[parent1]
                f2 = matingPool.solution[parent2]
            end
            if rand() <= Pm
                f1 = mutation(f1)
            end
            if rand() <= Pm
                f2 = mutation(f2)
            end
            # print("\tf1 : $f1");println("\tf2 : $f2")
            # f1 et f2 sont obtenus
            # Faudra les evaluer et les rajouter dans Offspring
            objective_1 = evalObjective(f1,c1)
            objective_2 = evalObjective(f1,c2)
            add(Offspring,indOffspring,f1,objective_1,objective_2,0,0)
            # println("add something")
            indOffspring = indOffspring+1

            objective_1 = evalObjective(f2,c1)
            objective_2 = evalObjective(f2,c2)
            add(Offspring,indOffspring,f2,objective_1,objective_2,0,0)
            indOffspring = indOffspring+1
        end
        # affichage(Offspring)
        println("#### Offspring population created ####")
        # Elitims ------------------------------------------------------------------
        println("#### Elitims ####")
        # println()
        R = combinedPopulation(population,Offspring)
        initRankandCrowdind(R)
        # affichage(R)
        ranking(R)
        crowding(R)
        # affichage(R)
        Elitims(R,population)
        println("#### New generation producted ####")
        affichage(population)
    end
    # retourner les individus de rang 1
    front1 = length(findall(x->x==1,population.rank))
    println()
    # println("Size of Yn with equivalent solution : $front1")
    println("----------------------------------------------------")
    println("Solutions :")
    # return X which is a tab of solution (each solution is a matrice n*n)
    X = Array{Array{Int,2},1}()
    tabSolution = []
    check = 0
    for i= 1:front1
        individu  = population.solution[i]
        # Eviter d'afficher les solutions equivalentes
        if !in(individu,tabSolution)
            push!(X,decode(individu))
            push!(tabSolution,individu)
            # Affichage
            print(population.solution[i])
            print(" | Z1 = ")
            print(population.obj1[i])
            print("\tZ2 = ")
            print(population.obj2[i])
            print("\n")
            if checkFeasibiliy(individu,w,b)
                check = check+1
            end
        end
    end
    front1 = length(tabSolution)
    println()
    println("-----------------------------------------------")
    println("Size of Yn without equivalent solution: $front1")
    if check == front1
        println("all solutions in yn are valid (knapsack inequality)")
    else
        println("some solutions don't satisfy knapsack inequality")
    end
    println("-----------------------------------------------")

    return X
end
# THis function return parents for the next generation
function selection(population,sizeTogenerate)
    #size must be integer
    sizeTogenerate = round(Int,trunc(sizeTogenerate))
    popsize = length(population.id)
    matingPool = Individu([],[],[],[],[],[])
    for gen = 1:sizeTogenerate
        parent1 = rand(1:popsize)
        parent2 = rand(1:popsize)
        while parent1 == parent2 && n >= 2
            parent2 = rand(1:n)
        end
        parent = tournoi(population,parent1,parent2)
        # println("\t\twinner : $parent")
        add(matingPool,gen,population.solution[parent],population.obj1[parent],population.obj2[parent],population.rank[parent],population.crowding[parent])
    end
    return matingPool
end

function tournoi(population,indX1,indX2)
    # print("betwen $indX1 and $indX2")
    if population.rank[indX1] < population.rank[indX2]
        # indX1 est choisi
        return indX1
    elseif population.rank[indX1] > population.rank[indX2]
        # indX2 est choisi
        return indX2
    else
        # return individu with the best crowding
        if population.crowding[indX1] < population.crowding[indX2]
            #return indX2
            return indX2
        elseif population.crowding[indX1] > population.crowding[indX2]
            #return indX1
            return indX1
        else
            # rand betwen
            if bitrand(1)[1]
                return indX1
            else
                return indX2
            end
        end

    end
end

function mutation(individu)
    n = length(individu)
    first  = rand(1:n)
    second = rand(1:n)
    while second == first
        second = rand(1:n)
    end
    # swap betwen first and second
    intermediate = individu[first]
    individu[first]  = individu[second]
    individu[second] = intermediate
    return individu
end
function crossover(p1,p2)
    f1 = OrderCrossover(p1,p2)
    f2 = OrderCrossover(p2,p1)
    return(f1,f2)
end
function OrderCrossover(p1,p2)
    n = length(p1)
    cutpoint1 = rand(1:n-1)
    cutpoint2 = rand(1:n-1)
    while cutpoint1 == cutpoint2 && n >= 2
        cutpoint2 = rand(1:n-1)
    end
    cut1 = min(cutpoint1,cutpoint2)
    cut2 = max(cutpoint1,cutpoint2)
    # println()
    # println("cut1 = $cut1")
    # println("cut2 = $cut2")
    #
    # println(p1)
    # println(p2)
    # println()

    fils = zeros(Int,n)
    for i = cut1+1:cut2
        # println("$i been fixed")
        fils[i] = p1[i]
    end
    tab1 = [p2[i] for i=cut2+1:n]
    tab2 = [p2[i] for i=1:cut2]
    tab = append!(tab1, tab2)
    # println("tab = $tab")
    j = 1
    for i=cut2+1:n
        while p2[j] in fils
            j = j+1
        end
        fils[i] = p2[j]
        j = j+1
    end
    for i=1:cut1
        while p2[j] in fils
            j = j+1
        end
        fils[i] = p2[j]
        j = j+1
    end

    # j = cut2+1
    # # println("j = $j")
    # for i = cut2+1:n
    #     while p2[j] in fils
    #         # println("move")
    #         j = j+1
    #         if j > n
    #             j = 1
    #         end
    #     end
    #     fils[i] = p2[j]
    #     j = j+1
    #     if j > n
    #         j = 1
    #     end
    # end
    # for i = 1:cut1
    #     while p2[j] in fils
    #         j = j+1
    #         if j > n
    #             j = 1
    #         end
    #     end
    #     fils[i] = p2[j]
    #     j = j+1
    # end
    return fils
end
function decode(individu)
    n = length(individu)
    x = zeros(Int,n,n)
    for i = 1:n
        j = individu[i]
        x[i,j] = 1
    end
    return x
end

function evalObjective(individu,cost)
    x = decode(individu)
    return dot(x,cost)
end
function add(population,ind,individu,objective_1,objective_2,rank,crowding)
    push!(population.id,ind)
    push!(population.solution,individu)
    push!(population.obj1,objective_1)
    push!(population.obj2,objective_2)
    push!(population.rank,rank)
    push!(population.crowding,crowding)
end
function affichage(population)
    nbIndividu = length(population.id)
    for i=1:nbIndividu
        print(population.id[i]);print("\t")
        print(population.solution[i]);print("\t")
        print(population.obj1[i]);print("\t")
        print(population.obj2[i]);print("\t")
        print(population.rank[i]);print("\t")
        print(population.crowding[i]);println()
    end
end
function checkFeasibiliy(solution,w,b)
    return (dot(decode(solution),w) <= b)
end
function ranking(population)
    rankFeasibleSolution   = zeros(0,4)
    rankInfeasibleSolution = zeros(0,4)
    # Initialise population rank to 0
    for i = 1:length(population.id)
        if checkFeasibiliy(population.solution[i],w,b)
            # solution is feasible
            rankFeasibleSolution = vcat(rankFeasibleSolution,[population.id[i] population.obj1[i] population.obj2[i] population.rank[i]])
        else
            # solution is not infeseable
            rankInfeasibleSolution = vcat(rankInfeasibleSolution,[population.id[i] population.obj1[i] population.obj2[i] population.rank[i]])
        end
    end
    # rankFeasibleSolution and rankInfeasibleSolution are ready
    indF1 = 2 #indice obj1 dans les tables rank
    indF2 = 3 #indice obj2 dans les tables rank
    indrank = 4 # indice rank dans les tables
    # rankFeasibleSolution   = lexicographically(rankFeasibleSolution,indF1)
    # rankInfeasibleSolution = lexicographically(rankInfeasibleSolution,indF1)
    # println()
    # affichageMatrice(rankFeasibleSolution)

    frontLevel(rankFeasibleSolution,indF1,indF2,indrank)
    frontLevel(rankInfeasibleSolution,indF1,indF2,indrank)

    # Fusionner les deux tables de rangs
    infeseableFront = maximum(rankFeasibleSolution[:,indrank])
    # println(infeseableFront)
    for i = 1:length(rankInfeasibleSolution[:,1])
        rankInfeasibleSolution[i,indrank] = rankInfeasibleSolution[i,indrank] + infeseableFront
    end
    popRank = vcat(rankFeasibleSolution,rankInfeasibleSolution)
    # Remplir la table d'origine (population) et la retourner
    for i = 1:length(popRank[:,1])
        indice = findfirst(x -> x == Int(popRank[i,1]),population.id[:,1])
        population.rank[indice] = Int(popRank[i,indrank])
    end
    # println("feasible")
    # affichageMatrice(rankFeasibleSolution)
    # println("infeseable")
    # affichageMatrice(rankInfeasibleSolution)
    # println("Union")
    # affichageMatrice(popRank)
    # println("ranking")
    # affichage(population)

end
function frontLevel(matriceOfpopulation,indF1,indF2,indrank)
    front = 1
    tableRng = copy(matriceOfpopulation)
    while !(isempty(tableRng))
        # println()
        # affichageMatrice(tableRng)
        yn = filteringYN(tableRng,indF1,indF2)
        sizeYn = length(yn[:,1])
        for i = 1:sizeYn
            # println(yn[i,1])
            # recuperer l'indice dans matriceOfpopulation
            positionInMatrice = findfirst(x -> x == yn[i,1],matriceOfpopulation[:,1])
            # Set le rang de l'indice
            matriceOfpopulation[positionInMatrice,indrank] = front
            # supprimer yn de tableRng
            positionIntableRng = findfirst(x -> x == yn[i,1],tableRng[:,1])
            tableRng = tableRng[setdiff(1:end,positionIntableRng), :]
        end
        front = front+1
    end
end
#-----------------------------------------------------------------------------------------------------------------------
function crowding(population)
    # crowding de tout le monde à 0
    frontMax = maximum(population.rank)
    indF1 = 2
    indF2 = 3
    indCrowding = 4
    for rg = 1:frontMax
        ind = findall(x->x==rg,population.rank)
        # println("rang $rg")
        # println(ind)
        I = [population.id[ind] population.obj1[ind] population.obj2[ind] population.crowding[ind]]
        for m = indF1:indF2
            I = lexicographically(I,m)
            I[1,indCrowding] = Inf
            I[end,indCrowding] = Inf
            # Ideal and anti-idealPoint
            if m == indF1
                maxFm = maximum(population.obj1)
                minFm = minimum(population.obj1)
            else
                maxFm = maximum(population.obj2)
                minFm = minimum(population.obj2)
            end
            for i = 2:length(I[:,1])-1
                I[i,indCrowding] = I[i,indCrowding] + (I[i+1,m]-I[i-1,m])/(maxFm-minFm)
            end
        end
        # A ce niveau les crowdings sont bon pour l'ensemble non domine de même front : I
        for i = 1:length(I[:,1])
            indice = findfirst(x -> x == Int(I[i,1]),population.id[:,1])
            population.crowding[indice] = I[i,indCrowding]
        end
        # println()
        # affichageMatrice(I)
    end
end
function combinedPopulation(population,Offspring)
    combined = copyPopulation(population)
    ind = length(population.id)
    for i = 1:length(Offspring.id)
        add(combined,(i+ind),Offspring.solution[i],Offspring.obj1[i],Offspring.obj2[i],Offspring.rank[i],Offspring.crowding[i])
    end
    return combined

end
function copyPopulation(population)
    pop = Individu([],[],[],[],[],[])
    for i = 1:length(population.id)
        add(pop,i,population.solution[i],population.obj1[i],population.obj2[i],population.rank[i],population.crowding[i])
    end
    return pop
end
function initRankandCrowdind(population)
    for i = 1:length(population.id)
        population.rank[i] = 0
        population.crowding[i] = 0
    end
end
function Elitims(R,population)
    # ordonner R suivant les rangs
    I = [R.id R.rank R.crowding]
    I = lexicographically(I,2)
    popsize = length(population.id)
    # println()
    # affichageMatrice(I)
    # ordonner dans I suivant les crowdings decroissant sur le même front
    indDebut  = 1
    indFin = 0
    indice = 0
    nbFront = maximum(I[:,2])
    # println(nbFront)
    tab = Int[]
    for eachFront = 1:nbFront
        frontElement = length(findall(x->x==eachFront,I[:,2]))
        indDebut = indFin+1
        indFin   = indDebut+frontElement-1
        # println("indBegin = $indDebut")
        # println("indEnd = $indFin")
        # recuperer le sous-ensemble nondominé
        tab1 = sortperm(I[indDebut:indFin,3], rev=true)
        tab1 = tab1 .+ indice
        tab = append!(tab,tab1)
        # println(tab)
        indice = indice+frontElement
    end
    # println("Result")
    # println(tab)
    # affichageMatrice(I[tab,:])
    # La matrice est bien ordonnée suivant les règles de l'elitisme
    # tab contient l'ordre defini
    for i = 1:popsize
        # change population[i] to R[Int(I[tab[i],1])]
        population.solution[i] = R.solution[Int(I[tab[i],1])]
        population.obj1[i] = R.obj1[Int(I[tab[i],1])]
        population.obj2[i] = R.obj2[Int(I[tab[i],1])]
        population.rank[i] = R.rank[Int(I[tab[i],1])]
        population.crowding[i] = R.crowding[Int(I[tab[i],1])]
    end
end
