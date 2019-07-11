function [ retval, lastMean, lastHessian ] = drawProposal(x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastHessian, RestrictedIndices, options )

df = 20;
[K,T] = size(yt);
[N,q] = size(x0);
ObsPriorMean = .5.*ones(1, N*q);
ObsPriorPrecision = eye(N*q).*1e-3;

LogLikePositive = @(v) PropLike (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -PropLike(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
themeanT = themean';
vecthemeanT = themeanT(:);
[~, p] = chol(Hessian);

V = Hessian \ eye(length(vecthemeanT));
n = length(vecthemeanT);
w1 = sqrt(chi2rnd(df,1)/df);
proposal = vecthemeanT + chol(V, 'lower')*normrnd(0,1, n,1)./w1;

for k = 1:length(RestrictedIndices)
    if  proposal(RestrictedIndices(k)) < 0
        w1 = sqrt(chi2rnd(df,1)/df);
        sigma = sqrt(V(RestrictedIndices(k)));
        alpha = -(themean(RestrictedIndices(k))*w1)/sigma;
        z = truncNormalRand(alpha, Inf,0, 1);
        proposal(RestrictedIndices(k)) = themean(RestrictedIndices(k)) + (sigma*z)/w1;
    end
end

reshapeProp = reshape(vecthemeanT, q, N)';
vecx0T = x0';
vecx0T = vecx0T(:);
proposalDist = @(q) mvstudenttpdf(q, vecthemeanT', V, df);
Num = LogLikePositive(reshapeProp) + proposalDist(vecx0T');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
u =log(unifrnd(0,1,1));
if u  <= alpha
    retval = reshapeProp;
else
    retval = x0;
end


end

