function [retval] = MHstepA(x0, themean, V, yt, obsPrecision, Ft, FtPrecision)
[K,T] = size(yt);
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = ones(1, K-1);
ObsPriorPrecision = .5.*eye(K-1);
LogLikePositive = @(v) LLRestrict (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
proposal = reshape(themean,K-1,1)  + chol(V, 'lower')*normrnd(0,1, K-1,1)./w1;
proposalDist = @(q) mvstudenttpdf(q, reshape(themean,1,K-1), V, df);
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

