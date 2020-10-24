## rotation + dilation
N = 256; iter = 50000
θx = 2π*rand(N)
rx = sqrt.(rand(N))
x = polar2cart(rx, θx)
disc_plot(x)

# 1. Learning steps
α = 0.02
anim = @animate for n in 1:iter
    global α
    if n > .99*iter
        α -= 0.02/(.01*iter)
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
end

plt = disc_plot(x)
# savefig(plt, "figs/selfSimNN_2D_rotdil_50000final.png")
