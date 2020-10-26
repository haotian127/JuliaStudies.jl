using Plots, Random

function isInDisc(P, r)
    return norm(P) <= r
end

function disc_plot(x; color=:red)
    scatter(x[:,1], x[:,2]; c=color, aspect_ratio=1, legend=false, grid=false, mswidth=0, xlims=[-1.1, 1.1], ylims=[-1.1, 1.1])
end

function polar2cart(r, θ)
    return hcat(r .* cos.(θ), r .* sin.(θ))
end

function cart2polar(x)
    N = size(x,1)
    r = [norm(x[i,:]) for i in 1:N]
    θ = [atan(x[i,2], x[i,1]) for i in 1:N]
    return r, θ
end


## Annealed Networks on a Bounded Disc
Random.seed!(2020)

# rotation
N = 256; iter = 5000
θx = 2π*rand(N)
rx = sqrt.(rand(N))
x = polar2cart(rx, θx)
disc_plot(x)

# 1. Learning steps
α = 0.1
anim = @animate for n in 1:iter
    # update y
    global θx, rx, x
    θ = 2π*rand()
    θy = (θx .+ θ) .% 2π
    ry = rx
    y = polar2cart(ry, θy)
    # find Λⱼ(n)
    nnx = Dict()
    for j in 1:N
        nnx[j] = []
    end
    for i in 1:N
        arr = [norm(x[j,:] - y[i,:]) for j in 1:N]
        min_val = minimum(arr)
        min_ind = findall(arr .== min_val)
        for j in min_ind
            nnx[j] = push!(nnx[j], i)
        end
    end
    for j in 1:N
        if nnx[j] != []
            x[j,:] += α * sum([y[i,:]-x[j,:] for i in nnx[j]])
        end
    end
    rx, θx = cart2polar(x)
    if n % 50 == 0
        disc_plot(x)
        title!("iter=$(n)")
    end
end when n % 50 == 0

gif(anim, "selfSimNN_2D_rotation.gif", fps = 5)



## dilation
N = 256; iter = 100000
θx = 2π*rand(N)
rx = sqrt.(rand(N))
x = polar2cart(rx, θx)
disc_plot(x)

# 1. Learning steps
α = 0.01
anim = @animate for n in 1:iter
    global α
    if n > .99*iter
        α -= 0.01/(.01*iter)
    end
    # update y
    global θx, rx, x
    d = (rand()-0.5)*2*log(16)
    θy = θx .+ (d < 0)*π
    ry = abs.(d) .* rx
    y = polar2cart(ry, θy)
    # find Λⱼ(n)
    nnx = Dict()
    for j in 1:N
        nnx[j] = []
    end
    for i in 1:N
        if ry[i] > 1
            continue
        end
        arr = [norm(x[j,:] - y[i,:]) for j in 1:N]
        min_val = minimum(arr)
        min_ind = findall(arr .== min_val)
        for j in min_ind
            nnx[j] = push!(nnx[j], i)
        end
    end
    for j in 1:N
        if nnx[j] != []
            x[j,:] += α * sum([y[i,:]-x[j,:] for i in nnx[j]])
        end
    end
    rx, θx = cart2polar(x)
    rx = min.(rx, 1)
    x = polar2cart(rx, θx)
    if n % 1000 == 0
        disc_plot(x)
        title!("iter=$(n)")
    end
end when n % 1000 == 0

gif(anim, "selfSimNN_2D_dilation3.gif", fps = 5)

disc_plot(x)

## rotation + dilation
N = 256; iter = 100000
θx = 2π*rand(N)
rx = sqrt.(rand(N))
x = polar2cart(rx, θx)
disc_plot(x)

# 1. Learning steps
α = 0.01
anim = @animate for n in 1:iter
    global α
    if n > .99*iter
        α -= 0.01/(.01*iter)
    end
    # update y
    global θx, rx, x
    θ = 2π*rand()
    d = (rand()-0.5)*2*log(16)
    θy = (θx .+ θ .+ (d < 0)*π) .% 2π
    ry = abs.(d) .* rx
    y = polar2cart(ry, θy)
    # find Λⱼ(n)
    nnx = Dict()
    for j in 1:N
        nnx[j] = []
    end
    for i in 1:N
        if !isInDisc(y[i,:], 1)
            continue
        end
        arr = [norm(x[j,:] - y[i,:]) for j in 1:N]
        min_val = minimum(arr)
        min_ind = findall(arr .== min_val)
        for j in min_ind
            nnx[j] = push!(nnx[j], i)
        end
    end
    for j in 1:N
        if nnx[j] != []
            x[j,:] += α * sum([y[i,:]-x[j,:] for i in nnx[j]])
        end
    end
    rx, θx = cart2polar(x)
    rx = min.(rx, 1)
    x = polar2cart(rx, θx)
    if n % 1000 == 0
        disc_plot(x)
        title!("iter=$(n)")
    end
end when n % 1000 == 0

gif(anim, "selfSimNN_2D_rotdil2.gif", fps = 5)

plt = disc_plot(x)
savefig(plt, "figs/selfSimNN_2D_rotdil_final2.png")

using NGWP
_, _, X = SunFlowerGraph(; N=256); sf_plt = disc_plot(X)
savefig(sf_plt, "figs/sunflower_arangement.png")
