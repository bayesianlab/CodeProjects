function [retval, lastMean, lastCovar] = identification1(x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastCovar,options )
[K,T] = size(yt);
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = 1.*ones(1, K);
ObsPriorPrecision = eye(K);
LL = @(guess) -LLRestrict(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);

[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);

[~, p] = chol(Hessian);

if p ~= 0
    themean = lastMean';
    V = lastCovar;
else
    lastMean = themean';
    lastCovar = Hessian\eye(K);
    V = lastCovar;
end
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);

LogLikePositive = @(v) LLRestrict (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
proposal = themean + chol(V, 'lower')*normrnd(0,1, K,1)./w1;
if proposal(1) < 0
    proposal(1) = proposal(1) * -1;
end
Num = LogLikePositive(proposal) + proposalDist(x0');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
u = log(unifrnd(0,1,1));
if u <= alpha
    retval = proposal;
else
    retval = x0;
end
end

