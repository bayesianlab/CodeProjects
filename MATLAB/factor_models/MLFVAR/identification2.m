function [ retval, lastMean, lastCovar] = identification2( x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastCovar, options  )

[K,T] = size(yt);
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = 1.*ones(1, K);
ObsPriorPrecision = eye(K);
LL = @(g) -LLRestrict (g, yt,ObsPriorMean,...
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
proposalDist = @(q) mvstudenttpdf(q, themean(2:end)', V(2:end,2:end), df);

LogLikePositive = @(v) LLRestrict (v, yt(2:end,:),ObsPriorMean(2:end),...
    ObsPriorPrecision(2:end,2:end), obsPrecision(2:end), Ft,FtPrecision);
proposal = themean + chol(V, 'lower')*normrnd(0,1, K,1)./w1;
proposal = proposal(2:end);
freeElems = x0(2:end);
Num = LogLikePositive(proposal) + proposalDist(freeElems');
Den = LogLikePositive(freeElems) + proposalDist(proposal');
alpha = Num - Den;
u = log(unifrnd(0,1,1));
if u <= alpha
    retval = [1;proposal];
else
    retval = x0;

end
end

