using vOptGeneric
using vOptSpecific
# using GLPK,GLPKMathProgInterface
using LinearAlgebra
using PyPlot
# vOptGeneric est juste utiliser pour tester le resultat obtenu
# vOptSpecific est utilisé pour initialiser la population initiale
m = vModel(solver = GLPKSolverMIP())
# using CPLEX
# m = vModel(solver = CplexSolver())
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
function rcapGenerique(m,c1,c2,w,b)
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
