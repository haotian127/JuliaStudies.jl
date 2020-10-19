macro myevalpoly(z,a...)
    isempty(a) && error("You forgot to pass coefficients!")
    ex = :($(a[length(a)]))
    for i in 1:length(a)-1
       ex = :($ex * $(z) + $(a[length(a)-i]) )
    end
    println(ex)
    ex
end

@myevalpoly 7 2 3 4 5
@evalpoly 7 2 3 4 5

##
function root2coeff(z::AbstractVector{T}) where T
    N = length(z)
    co = zeros(T, N+1)
    # The last coefficient is always one
    co[end] = 1
    # The outer loop adds one root at a time
    for j in 1:N, i in j:-1:1
        co[end-i] -= z[j]*co[end-i+1]
    end
    co
end
@show typemax(Int), typemax(Int128)
root2coeff(1:20)
root2coeff(Int128(1):20)

##
using LinearAlgebra
function poly_roots(z)
    len = length(z)
    # construct the ones part
    mat = diagm(-1 => ones(len-2))
    # insert coefficients
    mat[:, end] = -z[1:end-1]
    eigvals(mat)
end

## Calculate all the roots and plot it
using Random
Random.seed!(2020)
function wilkinson_poly_roots(n=100)
    # original coefficients
    coeff = root2coeff(Int128(1):20)
    rts = Vector{Complex{Float64}}[]
    # add perturbation
    for i in 1:n
        pert_coeff = coeff.*(1 .+ rand(21)*1e-6)
        push!(rts, poly_roots(pert_coeff))
    end
    rts
end
using Plots; gr()
function plt_wilkinson_roots(rts)
    # plot roots without perturbation
    plt = scatter(1:20, zeros(20), color = :green, markersize = 5, legend = false, grid = false, aspect_ratio = 1)
    for i in eachindex(rts)
        # plot roots with perturbation
        scatter!(plt, real.(rts[i]), imag.(rts[i]), color = :red, mscolor = :red, markersize = 2, shape = :star)
    end
    plt
end
wilkinson_poly_roots(100) |> plt_wilkinson_roots
