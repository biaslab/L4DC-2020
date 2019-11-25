module DataAR

import PolynomialRoots.roots
using Distributions

export generateAR, generateSIN, writeAR, readAR, generateHGFAR


function generate_coefficients(order::Int)
    stable = false
    true_a = []
    # Keep generating coefficients until we come across a set of coefficients
    # that correspond to stable poles
    while !stable
        true_a = randn(order)
        coefs =  append!([1.0], -true_a)
        #reverse!(coefs)
        if false in ([abs(root) for root in roots(coefs)] .> 1)
            continue
        else
            stable = true
        end
    end
    return true_a
end

function time_varying_variance(kappa, omega, vtop,n_samples)
    x1, x2 = Array{Float64}(undef,n_samples+1), Array{Float64}(undef,n_samples)
    x1[1] = randn()
    for i=1:n_samples
        x1[i+1] = x1[i] + sqrt(vtop)*randn()
        x2[i] = exp(kappa*x1[i+1] +omega)
    end
    return x1, x2
end


function generateHGFAR(num::Int, order::Int, kappa, omega, vtop)
    coefs = generate_coefficients(order)
    inits = randn(order)
    data = Vector{Vector{Float64}}(undef, num+3*order)
    data[1] = inits
    rw, tvar = time_varying_variance(kappa, omega, vtop, num+3*order)
    for i in 2:num+3*order
        data[i] = insert!(data[i-1][1:end-1], 1, rand(Distributions.Normal(coefs'data[i-1], sqrt(tvar[i])), 1)[1])
    end
    data = data[1+3*order:end]
    return coefs, data, tvar[1+3*order:end], rw[1+3*order:end]
end


function generateAR(num::Int, order::Int; nvar=1, stat=true, coefs=nothing)
    if isnothing(coefs) && stat
        coefs = generate_coefficients(order)
    else
        coefs = randn(order)
    end
    inits = randn(order)
    data = Vector{Vector{Float64}}(undef, num+3*order)
    data[1] = inits
    for i in 2:num+3*order
        data[i] = insert!(data[i-1][1:end-1], 1, rand(Distributions.Normal(coefs'data[i-1], sqrt(nvar[])), 1)[1])
    end
    data = data[1+3*order:end]
    return coefs, data
end

function generateSIN(num::Int, noise_variance=1/5)
    coefs = [2cos(1), -1]
    order = length(coefs)
    inits = [sin(1), sin(0)]
    data = Vector{Vector{Float64}}(undef, num+10*order)
    data[1] = inits
    for i in 2:num+10*order
        data[i] = insert!(data[i-1][1:end-1], 1, coefs'data[i-1])
        data[i][1] += sqrt(noise_variance)*randn()
    end
    data = data[1+10*order:end]
    return coefs, data
end

end  # module
