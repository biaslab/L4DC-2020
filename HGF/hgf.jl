module HGF

using ForneyLab
using FastGaussQuadrature
using LinearAlgebra
using ForwardDiff

include("exponential_linear_quadratic.jl")
include("gaussian_controlled_variance.jl")
include("rules_prototypes.jl")
include("update_rules.jl")

end  # module HGF
