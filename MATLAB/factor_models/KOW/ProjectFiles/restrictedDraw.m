function [ retval ] = restrictedDraw(x0, yt, obsPrecision, Ft, FtPrecision,...
    nEqns, lastMean, lastHessian, options )
% df = 20;
% ObsPriorMean = ones(1, nEqns-1);
% ObsPriorPrecision = eye(nEqns-1).*1e-5;
% w1 = sqrt(chi2rnd(df,1)/df);
% LogLikePositive = @(v) AproptoLLLevel3 (v, yt,ObsPriorMean,...
%     ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
% 
% LL = @(guess) -AproptoLLLevel3(guess, yt,ObsPriorMean,...
%     ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
% 
% 
% [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
% themean = themean(2:end);
% Hessian = Hessian(2:end,2:end);
% [~, p] = chol(Hessian);
% [themean, Hessian, lastMean, lastHessian] = ...
%     optimCheck(p, themean,Hessian, lastMean, lastHessian);
% 
% V = Hessian \ eye(length(themean));
% 
% proposal  = themean + chol(V,'lower')*normrnd(0,1,length(themean),1)./w1;
% proposalDist = @(q) mvstudenttpdf(q, themean', V, df);
% 
% Num = LogLikePositive([1;proposal]) + proposalDist(x0(2:end)');
% Den = LogLikePositive(x0) + proposalDist(proposal');
% alpha = Num - Den;
% if log(unifrnd(0,1,1)) <= alpha 
%     retval = [ 1;proposal ];
% else
%    retval = x0; 
% end

df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = ones(1, nEqns);
ObsPriorPrecision = eye(nEqns).*1e-5;
LogLikePositive = @(v) AproptoLL (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -AproptoLL(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
[~, p] = chol(Hessian);
[themean, Hessian, lastMean, lastHessian] = ...
    optimCheck(p, themean,Hessian, lastMean, lastHessian);
V = Hessian \ eye(length(themean));
n = length(themean);
proposal = themean(1:n) + chol(V(1:n,1:n), 'lower')*normrnd(0,1, n,1)./w1;
if proposal(1) < 0    
    sigma = sqrt(V(1,1));
    alpha = -(themean(1)*w1)/sigma;
    z = truncNormalRand(alpha, Inf,0, 1);
    restricteddraw = themean(1) + (sigma*z)/w1;
    lower = themean(2:n) + chol(V(2:n,2:n), 'lower')*normrnd(0,1, n-1,1)./w1;
    proposal = [restricteddraw;lower];
end
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);

Num = LogLikePositive(proposal) + proposalDist(x0');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
if log(unifrnd(0,1,1)) <= alpha 
    retval = proposal;
else
   retval = x0; 
end
end

