function [ retval, lastMean, lastCovar] = identification2_WithRestriction( x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastCovar, options  )
[K,T] = size(yt);
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = ones(1, K-1);

ObsPriorPrecision = .5.*eye(K-1);
LogLikePositive = @(v) LLRestrict (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -LLRestrict(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);

[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
[~, p] = chol(Hessian);
if p ~= 0
    themean = lastMean';
    V = lastCovar;
else
    lastMean = themean';
    lastCovar = Hessian\eye(K-1);
    V = lastCovar;
end

proposal = themean + chol(V, 'lower')*normrnd(0,1, K-1,1)./w1;
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);
Num = LogLikePositive(proposal) + proposalDist(x0');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
u = log(unifrnd(0,1,1));
if u <= alpha
    retval = [proposal];
else
    retval = x0;
end
end

