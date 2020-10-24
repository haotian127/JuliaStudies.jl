using Plots, Random

function angle2point(θ)
    N = length(θ)
    x = zeros(N,2)
    for i in 1:N
        x[i,:] = [cos(θ[i]), sin(θ[i])]
    end
    return x
end

function circle_plot(x; color=:red)
    scatter(x[:,1], x[:,2]; c=color, aspect_ratio=1, legend=false, grid=false, mswidth=0, xlims=[-1.1, 1.1], ylims=[-1.1, 1.1])
end

function state_vector(θx)
    sort!(θx)
    γ = zeros(N)
    γ[1] = θx[1]-θx[end]+2π
    for i in 2:N
        γ[i] = θx[i]-θx[i-1]
    end
    𝝓 = [γ[i]-2π/N for i in 1:N]
    return 𝝓
end

# 0. Initialize points on [0, 2π)
Random.seed!(2020)
N = 32; iter = 5000
θx = 2π*rand(N)
circle_plot(angle2point(θx))

# 1. Learning steps
α = 0.1
𝝓_norm = []
anim = @animate for i in 1:iter
    push!(𝝓_norm, norm(state_vector(θx)))
    θ = 2π*rand()
    θy = (θx .+ θ) .% 2π
    nnx = Dict()
    for j in 1:N
        nnx[j] = []
    end
    for i in 1:N
        arr = min.(abs.(θx .- θy[i]), 2π .- abs.(θx .- θy[i]))
        min_val = minimum(arr)
        min_ind = findall(arr .== min_val)
        for j in min_ind
            nnx[j] = push!(nnx[j], i)
        end
    end
    for j in 1:N
        if nnx[j] != []
            θx[j] += α * sum([θy[i]-θx[j]+(abs(θy[i]-θx[j])<π ? 0 : -sign(θy[i]-θx[j])*2π)  for i in nnx[j]])
        end
    end
    if i % 50 == 0
        circle_plot(angle2point(θx))
        title!("iter=$(i)")
    end
end when i % 50 == 0

gif(anim, "selfSimNN_1D.gif", fps = 5)

plot(𝝓_norm, legend=false)

# circle_plot(angle2point(θx))
