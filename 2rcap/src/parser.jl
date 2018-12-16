include("filtrage.jl")
function load1RcapInstance(fname)
    fname = "../instances/"*fname
    f = open(fname)
    n = parse(Int,readline(f))
    # println(n)
    c1 = zeros(Int,0,n)
    c2 = zeros(Int,n,n)
    w  = zeros(Int,0,n)
    b = 0
    for i = 1:n
        line = readline(f)
        line = split(line)
        line = map(x->parse(Int,x),line)
        # println(line)
        c1 = vcat(c1,reshape(line,(1,n)))
    end
    # la matrice w
    for i = 1:n
        line = readline(f)
        line = split(line)
        line = map(x->parse(Int,x),line)
        # println(line)
        w = vcat(w,reshape(line,(1,n)))
    end
    # matrice c1
    # affichageMatrice(c1)
    # println()
    # generer c2
    maxCost = maximum(c1)
    minCost = minimum(c2)
    for i=1:n
        for j=1:n
            c2[i,j] = rand(minCost:maxCost)
        end
    end
    # affichageMatrice(c2)
    # println()
    # matrice w
    # affichageMatrice(w)
    rho = 1
    b = Int(trunc((rho*(sum(w)/n))))
    # println("b = $b")
    # println(sum(w))
    return c1,c2,w,b
end
function load2RcapInstance(fname)
    fname = "../instances/"*fname
    f = open(fname)
    n = parse(Int,readline(f))
    # println(n)
    c1 = zeros(Int,0,n)
    c2 = zeros(Int,0,n)
    w  = zeros(Int,0,n)
    # la matrice c1
    for i = 1:n
        line = readline(f)
        line = split(line)
        line = map(x->parse(Int,x),line)
        # println(line)
        c1 = vcat(c1,reshape(line,(1,n)))
    end
    # la matrice c1
    for i = 1:n
        line = readline(f)
        line = split(line)
        line = map(x->parse(Int,x),line)
        # println(line)
        c2 = vcat(c2,reshape(line,(1,n)))
    end
    # la matrice w
    for i = 1:n
        line = readline(f)
        line = split(line)
        line = map(x->parse(Int,x),line)
        # println(line)
        w = vcat(w,reshape(line,(1,n)))
    end
    b = parse(Int,readline(f))
    # matrice c1
    # affichageMatrice(c1)
    # println()
    # affichageMatrice(c2)
    # println()
    # affichageMatrice(w)
    return c1,c2,w,b
end
function loadRandInstance(n,minCost,maxCost)
    minW = 5
    maxW = 30
    c1 = rand(minCost:maxCost,n,n)
    c2 = rand(minCost:maxCost,n,n)
    w  = rand(minW:maxW,n,n)
    rho = 1
    b = Int(trunc((rho*(sum(w)/n))))
    # println()
    # affichageMatrice(c1)
    # println()
    # affichageMatrice(c1)
    # println()
    # affichageMatrice(w)
    # println()
    # println("b = $b")
    # println(sum(w))
    return c1,c2,w,b
end
