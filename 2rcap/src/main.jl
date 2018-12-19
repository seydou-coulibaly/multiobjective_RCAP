using PyPlot
using Distributions
using Random
using LinearAlgebra
include("nsga2.jl")
include("parser.jl")
n = 10
minCost = 50
maxCost = 1000
fname = ["2rcap05.txt","RCAP5.txt","RCAP5_1_10.txt","RCAP10_0_50.txt","RCAP20.txt","RCAP50.txt","RCAP50_1_50.txt","RCAP100.txt","RCAP200.txt","RCAP300.txt","RCAP400.txt","RCAP500.txt"]
# de 1 à 12
instance = fname[8]
c1,c2,w,b = load1RcapInstance(instance)
# c1,c2,w,b = loadRandInstance(n,minCost,maxCost)
# c1,c2,w,b = load2RcapInstance(instance)
# println("c1")
# affichageMatrice(c1)
# println("c2")
# affichageMatrice(c2)
# println("w")
# affichageMatrice(w)
# println(b)
# X contient la solution (matrice)

# Algorithms inputs
popsize = 1000
nGenerations = 50
Pc = 0.70
Pm = 0.20
X = nsga2(c1,c2,w,b,popsize,nGenerations,Pc,Pm)
println()
