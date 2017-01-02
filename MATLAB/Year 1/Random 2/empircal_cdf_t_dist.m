%% T Distribution 3 D.F.
% Below is an attempt at showing convergence of a t
% to the limiting distribution Normal(0,1). 
%% Theoretical Considerations
% The t distribution has finite mean and variance. The 
% CLT applies. 
%% Optimality of Estimated Parameters
% The mean should be a good estimator. The t has 0 
% mean and a finite variance. The data should conform to the 
% CLT. 
% 
% 

%% Experiment
% 5,000 Monte Carlo simulations, sample sizes of 100, 1000, and
% 10,000 were taken from a t distribution. 
% Below is the result from 10,000 observations. 
clc
clear
loadTData
data = tDistribution;
x = -5:.01:3;
my = evcdf(x, 0, 1);
cdfplot(data(10, :))
hold on
plot(x, my, 'm')
title('T Emprical CDF')
legend('Emprical', 'Theoretical')
