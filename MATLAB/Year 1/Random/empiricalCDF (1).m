%% Cauchy Distributiton Shown With Empirical CDF
% Below is an attempt at showing convergence of a Cauchy
% to the limiting distribution Normal(0,1). 
%% Theoretical Considerations
% The Central Limit Theorem does not apply in the case of Cauchy.
% For the CLT to apply the sequence of random variables,  
% $X_i$ say, must have finite mean and variance. This the
% Cauchy distribution does not have. As a side note, the 
% CLT only applies to sequences of RV's whose MGF's exist
% in a open neightborhood of zero. The Cauchy does not have
% an existent MGF. Therefore, I would not expect the Cauchy to
% go to a Normal(0,1) in the limit.
%% Optimality of Parameters
% The biggest concern with the Cauchy is the spread of the 
% data. The median might be the most consistent with 
% the Normal (0,1) median, since the median is not susecptible
% to outliers. 

%% Experiment
% 5,000 Monte Carlo simulations, sample sizes of 100, 1000, and
% 10,000 were taken from a Cauchy distribution. 
% Below is the result from 10,000 observations. 
clc
clear
loadCauchyData;
x = -5:.01:5;
my = evcdf(x, 0, 1);
cdfplot(cauchyData(10, :))
hold on
plot(x, my, 'm')
title('Cauchy Emprical CDF')
legend('Emprical', 'Theoretical')



