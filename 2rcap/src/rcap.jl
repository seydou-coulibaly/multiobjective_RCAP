using vOptGeneric
using vOptSpecific
using GLPK,GLPKMathProgInterface
using LinearAlgebra
using PyPlot
# vOptGeneric est juste utiliser pour tester le resultat obtenu
# vOptSpecific est utilisé pour initialiser la population initiale
m = vModel(solver = GLPKSolverMIP())
# using CPLEX
# m = vModel(solver = CplexSolver())
function rcapGenerique(m,c1,c2,w,b)
    (n,n) = size(c1)
    @variable(m, x[1:n,1:n], Bin)
    @addobjective(m, Min, dot(x, c1))
    @addobjective(m, Min, dot(x, c2))
    @constraint(m, dot(x, w) <= b)
    @constraint(m,[i=1:n],sum(x[i,j] for j=1:n) == 1)
    @constraint(m,[j=1:n],sum(x[i,j] for i=1:n) == 1)

    solve(m, method=:dichotomy)
    tabSolution = Array{Array{Int,2},1}()
    Y_N = getY_N(m)
    for n = 1:length(Y_N)
        X = getvalue(x, n)
        push!(tabSolution,X)
        println("\t| z = ",Y_N[n])
        # println()
    end

    # f1 = map(y -> y[1], Y_N)
    # f2 = map(y -> y[2], Y_N)
    # xlabel("z1")
    # ylabel("z2")
    # plot(f1,f2,"bx", markersize = "6")
    # !isinteractive() && show()
    return tabSolution
end
#
function rcapSpecific(c1,c2)
    (n,n) = size(c1)
    id = set2LAP(n, c1, c2)
    z1,z2,solutions = vSolve(id)
    tabSolution = Array{Array{Int,1},1}()
    for i = 1:length(z1)
        # println("(" , z1[i], " | ", z2[i], ") : ", solutions[i,:])
        # println()
        push!(tabSolution,solutions[i,:])
        # println(tabSolution[i])
    end
    return tabSolution
end
# retourne une matrice, à coder pour l'utiliser dans nsga2
# rcapSolution = rcapGenerique(m,c1,c2,w,b)
# retourne un tableau, à utiliser dans nsga2 directement
# rcapSolution = rcapSpecific(c1,c2)
