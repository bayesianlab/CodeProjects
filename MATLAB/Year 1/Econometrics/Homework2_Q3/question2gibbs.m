%%  Question 2
clear
clc
imp_datab

% Rescale

X = [constant, x_1, x_2 ];
[r,c] = size(X);
b0 = [0,0,0]'

sig_sqd = 5;
[estimator, log_like, exitf, output, g, h] = maxOrdinalMinUnc(b0,...
    sig_sqd, X, y);
b0 = estimator
iHess = 10*eye(3);
iHess = inv(iHess);
% iHess = inv(h);

sims = 5000;
burnin = sims/10;
stoYs = 0;
stoBetas = zeros(sims,c);
stoBetas(1, :) = b0;
stoSigmas = zeros(sims, 1);

stoSigmas(1) = sig_sqd;
yStar= zeros(r, 1);



for gibb = 1:sims-1
    yStar(:,1) = trunc_normal(stoBetas(gibb,:), stoSigmas(gibb), X, y);
    stoBetas(gibb+1, :) = updateBetaPrior(b0, iHess, stoSigmas(gibb),...
        X, yStar);
    stoSigmas(gibb+1, :) = invertedGamma(stoBetas(gibb,:), X, yStar);
    
    
end



mean(stoBetas(burnin:sims, :))
std(stoBetas(burnin:sims,:))

    
