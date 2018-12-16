include("filtrage.jl")
using vOptGeneric
using vOptSpecific
using GLPK,GLPKMathProgInterface
using LinearAlgebra
m = vModel(solver = GLPKSolverMIP())
# using CPLEX
# m = vModel(solver = CplexSolver())
C1 = [13 14  7 2 11
      5  10 11 7 10
      7 19 9 16 19
      3 19 10 0 6
      12 9 2 4 15]
C2 = [ 1 13 15 18 3
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
(n,n) = size(C1)

@variable(m, x[1:n,1:n], Bin)
@addobjective(m, Min, dot(x, C1))
@addobjective(m, Min, dot(x, C2))
@constraint(m, dot(x, w) <= b)
@constraint(m,[i=1:n],sum(x[i,j] for j=1:n) == 1)
@constraint(m,[j=1:n],sum(x[i,j] for i=1:n) == 1)

solve(m, method=:dichotomy)

Y_N = getY_N(m)
for n = 1:length(Y_N)
    X = getvalue(x, n)
    affichageMatrice(X)
    # print(find(X))
    # print([i for i = 1:n for j = 1:n if X[i,j] == 1])
    println("\t| z = ",Y_N[n])
    println()
end

using PyPlot
f1 = map(y -> y[1], Y_N)
f2 = map(y -> y[2], Y_N)
xlabel("z1")
ylabel("z2")
plot(f1,f2,"bx", markersize = "6")
!isinteractive() && show()
