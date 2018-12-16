using PyPlot
using Distributions
using Random
using LinearAlgebra
include("function.jl")
# include("nsga.jl")
include("nsga2.jl")
# Decommentez la fonction souhaitée
#schafferFunction()
#kimFunction()
# cantileverProblem()
#gearTrain()

X = nsga2()
println()
