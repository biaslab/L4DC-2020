@structuredVariationalRule(:node_type => GaussianMeanPrecision,
                           :outbound_type => Message{Gaussian},
                           :inbound_types => (Nothing,Message{ExponentialLinearQuadratic},ProbabilityDistribution),
                           :name => SVBGaussianMeanPrecisionOutNED)

@structuredVariationalRule(:node_type => GaussianMeanPrecision,
                           :outbound_type => Message{Gaussian},
                           :inbound_types => (Message{ExponentialLinearQuadratic},Nothing,ProbabilityDistribution),
                           :name => SVBGaussianMeanPrecisionOutEND)

@marginalRule(:node_type => GaussianMeanPrecision,
              :inbound_types => (Message{Gaussian}, Message{ExponentialLinearQuadratic}, ProbabilityDistribution),
              :name => MGaussianMeanPrecisionGED)

@marginalRule(:node_type => GaussianMeanPrecision,
              :inbound_types => (Message{ExponentialLinearQuadratic}, Message{Gaussian}, ProbabilityDistribution),
              :name => MGaussianMeanPrecisionEGD)


@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{GaussianMeanVariance},
                           :inbound_types => (Nothing, Message{Gaussian}, ProbabilityDistribution, ProbabilityDistribution,ProbabilityDistribution),
                           :name          => SVBGaussianControlledVarianceOutNGDDD)

@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{GaussianMeanVariance},
                           :inbound_types => (Message{Gaussian},Nothing,ProbabilityDistribution, ProbabilityDistribution,ProbabilityDistribution),
                           :name          => SVBGaussianControlledVarianceXGNDDD)

@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{ExponentialLinearQuadratic},
                           :inbound_types => (ProbabilityDistribution,Nothing,ProbabilityDistribution,ProbabilityDistribution),
                           :name          => SVBGaussianControlledVarianceZDNDD)

@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{ExponentialLinearQuadratic},
                           :inbound_types => (ProbabilityDistribution,ProbabilityDistribution,Nothing,ProbabilityDistribution),
                           :name          => SVBGaussianControlledVarianceΚDDND)

@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{ExponentialLinearQuadratic},
                           :inbound_types => (ProbabilityDistribution,ProbabilityDistribution,ProbabilityDistribution,Nothing),
                           :name          => SVBGaussianControlledVarianceΩDDDN)

@marginalRule(:node_type     => GaussianControlledVariance,
              :inbound_types => (Message{Gaussian},Message{Gaussian},ProbabilityDistribution,ProbabilityDistribution,ProbabilityDistribution),
              :name          => MGaussianControlledVarianceGGDDD)

#
@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                     :outbound_type => Message{GaussianMeanVariance},
                     :inbound_types => (ProbabilityDistribution,Nothing,Message{Gaussian},ProbabilityDistribution),
                     :name          => SVBGaussianControlledVarianceZDGGD)
#
@structuredVariationalRule(:node_type     => GaussianControlledVariance,
                           :outbound_type => Message{GaussianMeanVariance},
                    :inbound_types => (ProbabilityDistribution,Message{Gaussian},Nothing,ProbabilityDistribution),
                    :name          => SVBGaussianControlledVarianceΚDGGD)
