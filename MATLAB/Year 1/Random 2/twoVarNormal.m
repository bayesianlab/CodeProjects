%% Two Variance Normal Distribution
% Below is an attempt at showing convergence of a Normal with
% two variances (1, 400) 
% to the limiting distribution Normal(0,1). 
%% Theoretical Considerations
% The CLT will apply. The weighted average of the two means will
% will be 40.9. Because it is already normal it will converge
% to a normal (0,1).
%% Optimality of Estimated Parameters
% All of the parameters should be similar to the Normal (0,1). 
% The spread will be larger because the variance is larger but 
% otherwise it will look the same. 

%% Experiment
% 5,000 Monte Carlo simulations, sample sizes of 100, 1000, and
% 10,000 were taken from the two variance Normal distribution. 
% Below is the result from 10,000 observations.
clc
clear
loadTwoVarianceNormal
x = -3:.01:3;
theoretical = evcdf(x, 0, 1);
cdfplot(twoVarianceNormal(7,:))
hold on
plot(x, theoretical, 'm')
title('Two Variance Normal Emprical CDF')
legend('Emprical', 'Theoretical')
