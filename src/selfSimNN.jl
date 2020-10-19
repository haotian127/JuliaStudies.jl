using Plots

function angle2point(θ)
    N = length(θ)
    x = zeros(N,2)
    for i in 1:N
        x[i,:] = [cos(θ[i]), sin(θ[i])]
    end
    return x
end

function circle_plot(x)
    scatter(x[:,1], x[:,2]; c=:red, aspect_ratio=1, legend=false, grid=false, mswidth=0)
end

# 0. Initialize points on [0, 2π)
N = 32
θx = 2π*rand(N)
x = angle2point(θx)
circle_plot(x)

# 1. Learning steps
α = 0.1
for i in 1:5000
    θ = 2π*rand()
    θy = (θx .+ θ) .% 2π
    for j in 1:N
        findmin(θy-θx[j])
        θx[j] += α * sum()
