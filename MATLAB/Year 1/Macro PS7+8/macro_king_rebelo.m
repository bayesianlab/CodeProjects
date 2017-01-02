%% King Rebelo Simulation
clear
clc

alpha = .3333;
beta= .99;
b = 1;
rho = .90;

n_steady = (1-alpha)/(b*(1-(alpha*beta)) + ( 1- alpha));

mcSims = 100;
periods = 250;

consumption_variance = zeros(mcSims, 1);
output_variance = zeros(mcSims, 1);
hrs_variance = zeros(mcSims, 1);
capital_variance = zeros(mcSims, 1);
for sim = 1:mcSims
    lnA_t = zeros(periods+1,1);
    lnA_t(1,1) = normrnd(0, .0072);
    k_steady = (alpha*beta*exp(lnA_t(1,1))*(n_steady^(1-alpha))^...
        (1/(1-alpha)));

    k_state = zeros(periods+1,1);
    k_state(1,1) = log(k_steady);

    output_store = zeros(periods + 1,1);
    output_store(1,1) = output(exp(lnA_t(1,1)), k_steady, n_steady);

    cons_store = zeros(periods + 1,1);
    cons_store(1,1) = consumption_policy(exp(lnA_t(1,1)), k_steady,...
        n_steady);

    hrs_store = zeros(periods + 1, 1);
    hrs_store(1,1) = log(n_steady);
    for p = 1 : periods
        A_t = exp(lnA_t(p,1));
        k_t = exp(k_state(p,1));
        c_t = exp(cons_store(p,1));
        n_t = exp(hrs_store(p,1));
        
        cons_store(p+1, 1) = consumption_policy(A_t, k_t, n_t);
        output_store(p+1, 1) = output(A_t, k_t, n_t);
        k_state(p+1,1) = capital_policy(A_t, k_t, n_t);
        hrs_store(p+1,1) = (1-alpha)/(b*(1-(alpha*beta)) + ( 1- alpha));
        
        lnA_t(p+1,1) = rho*lnA_t(p,1) + normrnd(0, .0072);

    end
    cons_store(1,:) = [];
    output_store(1,:) = [];
    k_state(1,:) = [];
    hrs_store(1,:) =[];

    consumption_variance(sim,1) = var(cons_store);
    output_variance(sim,1) = var(output_store);
    hrs_variance(sim,1) = var(hrs_store);
    capital_variance(sim,1) = var(k_state);
end

str = sprintf([ 'Mean Consumption variance %.3f \nMean output variance %.3f\n',...
     'Mean hours variance %.3f \nMean capital variance %.3f'],...
mean(consumption_variance),...
mean(output_variance),...
mean(hrs_variance),...
mean(capital_variance));
disp(str)

%% Interpretation
% King-Rebelo found .61 = C, 1.39 = Y, .67 = N,  but our esitmates returned
% .005 = C, .005 = Y, 0.0 = N and .005 = K. The difference can be explained
% by the fact that our model had far less perturbations than the
% King-Rebelo paper, and therefore much smaller variances on all the
% paramters. 


