import ForneyLab: collectStructuredVariationalNodeInbounds, recognitionFactorId, localRecognitionFactorization, ultimatePartner, marginalString

export
ruleSVBGaussianControlledVarianceOutNGDDD,
ruleSVBGaussianControlledVarianceXGNDDD,
ruleSVBGaussianControlledVarianceZDNDD,
ruleSVBGaussianControlledVarianceΚDDND,
ruleSVBGaussianControlledVarianceΩDDDN,
ruleMGaussianControlledVarianceGGDDD,
collectStructuredVariationalNodeInbounds,
ruleSPEqualityGaussianGCV,
ruleSVBGaussianMeanPrecisionOutNED,
ruleSVBGaussianMeanPrecisionOutEND,
ruleMGaussianMeanPrecisionGED,
ruleMGaussianMeanPrecisionEGD


function ruleSVBGaussianControlledVarianceOutNGDDD(dist_out::Nothing,
                                                   msg_x::Message{F, Univariate},
                                                   dist_z::ProbabilityDistribution{Univariate},
                                                   dist_κ::ProbabilityDistribution{Univariate},
                                                   dist_ω::ProbabilityDistribution{Univariate}) where F<:Gaussian

    dist_x = convert(ProbabilityDistribution{Univariate,GaussianMeanVariance},msg_x.dist)
    m_x = dist_x.params[:m]
    v_x = dist_x.params[:v]
    m_z, v_z = unsafeMeanCov(dist_z)
    m_κ, v_κ = unsafeMeanCov(dist_κ)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    ksi = m_κ^2*v_z + m_z^2*v_κ+v_z*v_κ
    A = exp(-m_ω+v_ω/2)
    B = exp(-m_κ*m_z + ksi/2)


    return Message(Univariate, GaussianMeanVariance, m=m_x, v=v_x+inv(A*B))
end

function ruleSVBGaussianControlledVarianceXGNDDD(msg_out::Message{F, Univariate},
                                                   dist_x::Nothing,
                                                   dist_z::ProbabilityDistribution{Univariate},
                                                   dist_κ::ProbabilityDistribution{Univariate},
                                                   dist_ω::ProbabilityDistribution{Univariate}) where F<:Gaussian

    dist_out = convert(ProbabilityDistribution{Univariate,GaussianMeanVariance},msg_out.dist)
    m_out = dist_out.params[:m]
    v_out = dist_out.params[:v]
    m_z, v_z = unsafeMeanCov(dist_z)
    m_κ, v_κ = unsafeMeanCov(dist_κ)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    ksi = m_κ^2*v_z + m_z^2*v_κ+v_z*v_κ
    A = exp(-m_ω+v_ω/2)
    B = exp(-m_κ*m_z + ksi/2)

    return Message(Univariate, GaussianMeanVariance, m=m_out, v=v_out+inv(A*B))
end


function ruleSVBGaussianControlledVarianceZDNDD(dist_out_x::ProbabilityDistribution{Multivariate, F},
                                                dist_z::Nothing,
                                                dist_κ::ProbabilityDistribution{Univariate},
                                                dist_ω::ProbabilityDistribution{Univariate}) where F<:Gaussian

    dist_out_x = convert(ProbabilityDistribution{Multivariate,GaussianMeanVariance},dist_out_x)
    m = dist_out_x.params[:m]
    v = dist_out_x.params[:v]
    m_κ, v_κ = unsafeMeanCov(dist_κ)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    Psi = (m[1]-m[2])^2+v[1,1]+v[2,2]-v[1,2]-v[2,1]
    A = exp(-m_ω+v_ω/2)

    return Message(Univariate, ExponentialLinearQuadratic, a=m_κ, b=Psi*A,c=-m_κ,d=v_κ)
end


function ruleSVBGaussianControlledVarianceΚDDND(dist_out_x::ProbabilityDistribution{Multivariate, F},
                                                dist_z::ProbabilityDistribution{Univariate},
                                                dist_κ::Nothing,
                                                dist_ω::ProbabilityDistribution{Univariate}) where F<:Gaussian

    dist_out_x = convert(ProbabilityDistribution{Multivariate,GaussianMeanVariance},dist_out_x)
    m = dist_out_x.params[:m]
    v = dist_out_x.params[:v]
    m_z, v_z = unsafeMeanCov(dist_z)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    Psi = (m[1]-m[2])^2+v[1,1]+v[2,2]-v[1,2]-v[2,1]
    A = exp(-m_ω+v_ω/2)

    return Message(Univariate, ExponentialLinearQuadratic, a=m_z, b=Psi*A,c=-m_z,d=v_z)
end


function ruleSVBGaussianControlledVarianceΩDDDN(dist_out_x::ProbabilityDistribution{Multivariate, F},
                                                dist_z::ProbabilityDistribution{Univariate},
                                                dist_κ::ProbabilityDistribution{Univariate},
                                                dist_ω::Nothing) where F<:Gaussian

    dist_out_x = convert(ProbabilityDistribution{Multivariate,GaussianMeanVariance},dist_out_x)
    m = dist_out_x.params[:m]
    v = dist_out_x.params[:v]
    m_z, v_z = unsafeMeanCov(dist_z)
    m_κ, v_κ = unsafeMeanCov(dist_κ)

    Psi = (m[1]-m[2])^2+v[1,1]+v[2,2]-v[1,2]-v[2,1]
    ksi = m_κ^2*v_z + m_z^2*v_κ+v_z*v_κ
    B = exp(-m_κ*m_z + ksi/2)

    return Message(Univariate, ExponentialLinearQuadratic, a=1.0, b=Psi*B,c=-1.0,d=0.0)
end


function ruleMGaussianControlledVarianceGGDDD(msg_out::Message{F1, Univariate},
                                              msg_x::Message{F2, Univariate},
                                              dist_z::ProbabilityDistribution{Univariate},
                                              dist_κ::ProbabilityDistribution{Univariate},
                                              dist_ω::ProbabilityDistribution{Univariate}) where {F1 <: Gaussian, F2 <: Gaussian}
    dist_out = convert(ProbabilityDistribution{Univariate,GaussianMeanPrecision},msg_out.dist)
    dist_x = convert(ProbabilityDistribution{Univariate,GaussianMeanPrecision},msg_x.dist)
    m_x = dist_x.params[:m]
    w_x = dist_x.params[:w]
    m_out = dist_out.params[:m]
    w_out = dist_out.params[:w]
    m_z, v_z = unsafeMeanCov(dist_z)
    m_κ, v_κ = unsafeMeanCov(dist_κ)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    ksi = m_κ^2*v_z + m_z^2*v_κ+v_z*v_κ
    A = exp(-m_ω+v_ω/2)
    B = exp(-m_κ*m_z + ksi/2)
    W = [w_out+A*B -A*B; -A*B w_x+A*B]
    m = inv(W)*[m_out*w_out; m_x*w_x]

    return ProbabilityDistribution(Multivariate, GaussianMeanPrecision, m=m, w=W)

end


function ruleMGaussianControlledVarianceDGGD(dist_out_x::ProbabilityDistribution{Multivariate, F1},
                                             msg_z::Message{F2, Univariate},
                                             msg_κ::Message{F3, Univariate},
                                             dist_ω::ProbabilityDistribution{Univariate}) where {F1<:Gaussian,F2<:Gaussian,F3<:Gaussian}

    dist_out_x = convert(ProbabilityDistribution{Multivariate,GaussianMeanVariance},dist_out_x)
    m = dist_out_x.params[:m]
    v = dist_out_x.params[:v]
    m_z, v_z = unsafeMeanCov(msg_z.dist)
    m_κ, v_κ = unsafeMeanCov(msg_κ.dist)
    m_ω, v_ω = unsafeMeanCov(dist_ω)

    Psi = (m[1]-m[2])^2+v[1,1]+v[2,2]-v[1,2]-v[2,1]
    A = exp(-m_ω+v_ω/2)
    h(x) = -0.5*((x[1]-m_κ)^2/v_κ +(x[2]-m_z)^2/v_z + x[1]*x[2] + A*Psi*exp(-x[1]*x[2]))
    newton_m, newton_v = NewtonMethod(h,[m_κ; m_z],10)
    # dist = ProbabilityDistribution(Multivariate,GaussianMeanVariance,m=newton_m,v=newton_v)*ProbabilityDistribution(Multivariate,GaussianMeanVariance,m=[m_κ;m_z], v=[v_κ 0.0;0.0 v_z])

    return ProbabilityDistribution(Multivariate,GaussianMeanVariance,m=newton_m,v=newton_v)
end


# ###Custom inbounds
function collectStructuredVariationalNodeInbounds(node::GaussianControlledVariance, entry::ScheduleEntry, interface_to_msg_idx::Dict{Interface, Int})
    # Collect inbounds
    inbounds = String[]
    entry_recognition_factor_id = recognitionFactorId(entry.interface.edge)
    local_cluster_ids = localRecognitionFactorization(entry.interface.node)

    recognition_factor_ids = Symbol[] # Keep track of encountered recognition factor ids
    for node_interface in entry.interface.node.interfaces
        inbound_interface = ultimatePartner(node_interface)
        node_interface_recognition_factor_id = recognitionFactorId(node_interface.edge)

        if node_interface == entry.interface
            # Ignore marginal of outbound edge
            push!(inbounds, "nothing")
        elseif (inbound_interface != nothing) && isa(inbound_interface.node, Clamp)
            # Hard-code marginal of constant node in schedule
            push!(inbounds, marginalString(inbound_interface.node))
        elseif node_interface_recognition_factor_id == entry_recognition_factor_id
            # Collect message from previous result
            inbound_idx = interface_to_msg_idx[inbound_interface]
            push!(inbounds, "messages[$inbound_idx]")
        elseif !(node_interface_recognition_factor_id in recognition_factor_ids)
            # Collect marginal from marginal dictionary (if marginal is not already accepted)
            marginal_idx = local_cluster_ids[node_interface_recognition_factor_id]
            push!(inbounds, "marginals[:$marginal_idx]")
        end

        push!(recognition_factor_ids, node_interface_recognition_factor_id)
    end

    return inbounds
end

# ###Custom inbounds
function collectStructuredVariationalNodeInbounds(node::GaussianMeanPrecision, entry::ScheduleEntry, interface_to_msg_idx::Dict{Interface, Int})
    # Collect inbounds
    inbounds = String[]
    entry_recognition_factor_id = recognitionFactorId(entry.interface.edge)
    local_cluster_ids = localRecognitionFactorization(entry.interface.node)

    recognition_factor_ids = Symbol[] # Keep track of encountered recognition factor ids
    for node_interface in entry.interface.node.interfaces
        inbound_interface = ultimatePartner(node_interface)
        node_interface_recognition_factor_id = recognitionFactorId(node_interface.edge)

        if node_interface == entry.interface
            # Ignore marginal of outbound edge
            if (entry.msg_update_rule == SVBGaussianMeanPrecisionOutNED) || (entry.msg_update_rule == SVBGaussianMeanPrecisionOutEND)
                inbound_idx = interface_to_msg_idx[inbound_interface]
                push!(inbounds, "messages[$inbound_idx]")
            else
                push!(inbounds, "nothing")
            end
        elseif (inbound_interface != nothing) && isa(inbound_interface.node, Clamp)
            # Hard-code marginal of constant node in schedule
            push!(inbounds, marginalString(inbound_interface.node))
        elseif node_interface_recognition_factor_id == entry_recognition_factor_id
            # Collect message from previous result
            inbound_idx = interface_to_msg_idx[inbound_interface]
            push!(inbounds, "messages[$inbound_idx]")
        elseif !(node_interface_recognition_factor_id in recognition_factor_ids)
            # Collect marginal from marginal dictionary (if marginal is not already accepted)
            marginal_idx = local_cluster_ids[node_interface_recognition_factor_id]
            push!(inbounds, "marginals[:$marginal_idx]")
        end

        push!(recognition_factor_ids, node_interface_recognition_factor_id)
    end

    return inbounds
end


# Updates for equality
ruleSPEqualityGaussianGCV(msg_1::Message{F1},msg_2::Message{F2},msg_3::Nothing) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_1.dist,msg_2.dist))
ruleSPEqualityGaussianGCV(msg_1::Message{F2},msg_2::Message{F1},msg_3::Nothing) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_1.dist,msg_2.dist))
ruleSPEqualityGaussianGCV(msg_1::Message{F1},msg_2::Nothing,msg_3::Message{F2}) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_1.dist,msg_3.dist))
ruleSPEqualityGaussianGCV(msg_1::Message{F2},msg_2::Nothing,msg_3::Message{F1}) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_1.dist,msg_3.dist))
ruleSPEqualityGaussianGCV(msg_1::Nothing,msg_2::Message{F1},msg_3::Message{F2}) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_2.dist,msg_3.dist))
ruleSPEqualityGaussianGCV(msg_1::Nothing,msg_2::Message{F2},msg_3::Message{F1}) where {F1<:Gaussian, F2<:ExponentialLinearQuadratic} = Message(prod!(msg_2.dist,msg_3.dist))

mutable struct SPEqualityGaussianGCV <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityGaussianGCV}) = Message{Gaussian}
function isApplicable(::Type{SPEqualityGaussianGCV}, input_types::Vector{Type})
    nothing_inputs = 0
    gaussian_inputs = 0
    exp_lin_quad_inputs = 0
    for input_type in input_types
        if input_type == Nothing
            nothing_inputs += 1
        elseif matches(input_type, Message{Gaussian})
            gaussian_inputs += 1
        elseif matches(input_type, Message{ExponentialLinearQuadratic})
            exp_lin_quad_inputs += 1
        end
    end

    return (nothing_inputs == 1) && (gaussian_inputs == 1) && (exp_lin_quad_inputs == 1)
end

# GaussianMeanPrecision updates
function ruleSVBGaussianMeanPrecisionOutNED(msg_out::Message{F,Univariate},
                                   msg_mean::Message{ExponentialLinearQuadratic},
                                   dist_prec::ProbabilityDistribution) where F<:Gaussian
    dist_mean = msg_mean.dist
    message_prior = ruleSVBGaussianMeanPrecisionOutVGD(nothing, msg_out,dist_prec)
    dist_prior = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance},message_prior.dist)
    approx_dist = dist_prior*msg_mean.dist

    return Message(GaussianMeanVariance, m=unsafeMean(approx_dist), v=unsafeCov(approx_dist) + cholinv(unsafeMean(dist_prec)))

end

function ruleSVBGaussianMeanPrecisionOutEND(msg_out::Message{ExponentialLinearQuadratic},
                                            msg_mean::Message{F, Univariate},
                                            dist_prec::ProbabilityDistribution) where F<:Gaussian

    dist_out = msg_out.dist
    message_prior = ruleSVBGaussianMeanPrecisionOutVGD(nothing, msg_mean,dist_prec)
    dist_prior = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance},message_prior.dist)
    approx_dist = dist_prior*msg_out.dist

    return Message(GaussianMeanVariance, m=unsafeMean(approx_dist), v=unsafeCov(approx_dist) + cholinv(unsafeMean(dist_prec)))

end


function ruleMGaussianMeanPrecisionGED(
    msg_out::Message{F, Univariate},
    msg_mean::Message{ExponentialLinearQuadratic},
    dist_prec::ProbabilityDistribution) where F<:Gaussian

    d_out = convert(ProbabilityDistribution{Univariate, GaussianWeightedMeanPrecision}, msg_out.dist)
    message_prior = ruleSVBGaussianMeanPrecisionOutVGD(nothing, msg_mean,dist_prec)
    dist_prior = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance},message_prior.dist)
    d_approx = dist_prior*msg_out.dist
    d_approx_mean = convert(ProbabilityDistribution{Univariate, GaussianWeightedMeanPrecision},d_approx)
    xi_y = d_out.params[:xi]
    W_y = d_out.params[:w]
    xi_m = d_approx_mean.params[:xi]
    W_m = d_approx_mean.params[:w]
    W_bar = unsafeMean(dist_prec)

    return ProbabilityDistribution(Multivariate, GaussianWeightedMeanPrecision, xi=[xi_y; xi_m], w=[W_y+W_bar -W_bar; -W_bar W_m+W_bar])
end

function ruleMGaussianMeanPrecisionEGD(
    msg_out::Message{ExponentialLinearQuadratic},
    msg_mean::Message{F, Univariate},
    dist_prec::ProbabilityDistribution) where F<:Gaussian

    d_mean = convert(ProbabilityDistribution{Univariate, GaussianWeightedMeanPrecision}, msg_mean.dist)
    message_prior = ruleSVBGaussianMeanPrecisionOutVGD(nothing, msg_mean,dist_prec)
    dist_prior = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance},message_prior.dist)
    d_approx = dist_prior*msg_out.dist
    d_approx_out = convert(ProbabilityDistribution{Univariate, GaussianWeightedMeanPrecision},d_approx)
    xi_y = d_approx_out.params[:xi]
    W_y = d_approx_out.params[:w]
    xi_m = d_mean.params[:xi]
    W_m = d_mean.params[:w]
    W_bar = unsafeMean(dist_prec)

    return ProbabilityDistribution(Multivariate, GaussianWeightedMeanPrecision, xi=[xi_y; xi_m], w=[W_y+W_bar -W_bar; -W_bar W_m+W_bar])
end
