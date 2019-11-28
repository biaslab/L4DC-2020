import ForneyLab: SoftFactor, @ensureVariables, generateId, addNode!, associate!,
                  averageEnergy, Interface, Variable, slug, ProbabilityDistribution,
                  differentialEntropy, unsafeLogMean, unsafeMean, unsafeCov, unsafePrecision, unsafeMeanCov, Univariate, Gaussian, prod!

export ExponentialLinearQuadratic, prod!

"""
Description:
    f(out,a,b,c,d) = exp(-0.5(a*out + b*exp(cx+dx^2/2)))

Interfaces:

    1. out
    2. a
    3. b
    4. c
    5. d

"""
mutable struct ExponentialLinearQuadratic<: SoftFactor
    id::Symbol
    interfaces::Vector{Interface}
    i::Dict{Symbol,Interface}

    function ExponentialLinearQuadratic(out, a, b, c, d; id=generateId(ExponentialLinearQuadratic))
        @ensureVariables(out, a, b, c, d)
        self = new(id, Array{Interface}(undef, 5), Dict{Symbol,Interface}())
        addNode!(currentGraph(), self)
        self.i[:out] = self.interfaces[1] = associate!(Interface(self), out)
        self.i[:a] = self.interfaces[2] = associate!(Interface(self), a)
        self.i[:b] = self.interfaces[3] = associate!(Interface(self), b)
        self.i[:c] = self.interfaces[4] = associate!(Interface(self), c)
        self.i[:d] = self.interfaces[5] = associate!(Interface(self), d)

        return self
    end
end

slug(::Type{ExponentialLinearQuadratic}) = "ELQ"

format(dist::ProbabilityDistribution{Univariate, ExponentialLinearQuadratic}) = "$(slug(ExponentialLinearQuadratic))(a=$(format(dist.params[:a])), b=$(format(dist.params[:b])), c=$(format(dist.params[:c])), d=$(format(dist.params[:d])))"

ProbabilityDistribution(::Type{Univariate}, ::Type{ExponentialLinearQuadratic}; a=1.0,b=1.0,c=1.0,d=1.0)= ProbabilityDistribution{Univariate, ExponentialLinearQuadratic}(Dict(:a=>a, :b=>b, :c=>c, :d=>d))
ProbabilityDistribution(::Type{ExponentialLinearQuadratic}; a=1.0,b=1.0,c=1.0,d=1.0) = ProbabilityDistribution{Univariate, ExponentialLinearQuadratic}(Dict(:a=>a, :b=>b, :c=>c, :d=>d))

# This is ugly but @symmetrical sucks
function prod!(x::ProbabilityDistribution{Univariate, ExponentialLinearQuadratic},
               y::ProbabilityDistribution{Univariate, F1},
               z::ProbabilityDistribution{Univariate, GaussianMeanVariance}=ProbabilityDistribution(Univariate, GaussianMeanVariance, m=0.0,v=1.0)) where F1<:Gaussian

    dist_y = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance}, y)
    m_y, v_y = unsafeMeanCov(dist_y)
    a = x.params[:a]
    b = x.params[:b]
    c = x.params[:c]
    d = x.params[:d]
    p = 20

    g(x) = exp(-0.5*(a*x+b*exp(c*x+d*x^2/2)))
    normalization_constant = quadrature(g,dist_y,p)
    t(x) = x*g(x)/normalization_constant
    mean = quadrature(t,dist_y,p)
    s(x) = (x-mean)^2*g(x)/normalization_constant
    var = quadrature(s,dist_y,p)

    z.params[:m] = mean
    z.params[:v] = var

    return z
end

function prod!(x::ProbabilityDistribution{Univariate, F1},
               y::ProbabilityDistribution{Univariate, ExponentialLinearQuadratic},
               z::ProbabilityDistribution{Univariate, GaussianMeanVariance}=ProbabilityDistribution(Univariate, GaussianMeanVariance, m=0.0,v=1.0)) where F1<:Gaussian

    dist_x = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance}, x)
    m_x, v_x = unsafeMeanCov(dist_x)
    a = y.params[:a]
    b = y.params[:b]
    c = y.params[:c]
    d = y.params[:d]
    p = 20

    g(x) = exp(-0.5*(a*x+b*exp(c*x+d*x^2/2)))
    normalization_constant = quadrature(g,dist_x,p)
    t(x) = x*g(x)/normalization_constant
    mean = quadrature(t,dist_x,p)
    s(x) = (x-mean)^2*g(x)/normalization_constant
    var = quadrature(s,dist_x,p)

    z.params[:m] = mean
    z.params[:v] = var

    return z
end

function quadrature(g::Function,d::ProbabilityDistribution{Univariate,GaussianMeanVariance},p::Int64)
    sigma_points, sigma_weights = gausshermite(p)
    m, v = ForneyLab.unsafeMeanCov(d)
    result = 0.0
    for i=1:p
        result += sigma_weights[i]*g(m+sqrt(2*v)*sigma_points[i])/sqrt(pi)
    end
    return result
end
