function [ retval, lastMean, lastHessian ] = drawProposal(x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastHessian, RestrictedIndices, options )

df = 20;
[K,T] = size(yt);

ObsPriorMean = .5.*ones(1, K);
ObsPriorPrecision = eye(K).*1e-3;

LogLikePositive = @(v) PropLike (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -PropLike(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
[~, p] = chol(Hessian);
[themean, Hessian, lastMean, lastHessian] = ...
    optimCheck(p, themean,Hessian, lastMean, lastHessian);
V = Hessian \ eye(length(themean));
n = length(themean);

proposal = themean + chol(V, 'lower')*normrnd(0,1, n,1)./w1;

for k = 1:levels
    if  proposal(RestrictedIndices(k)) < 0
        w1 = sqrt(chi2rnd(df,1)/df);
        sigma = sqrt(V(RestrictedIndices(k)));
        alpha = -(themean(RestrictedIndices(k))*w1)/sigma;
        z = truncNormalRand(alpha, Inf,0, 1);
        proposal(RestrictedIndices(k)) = themean(RestrictedIndices(k)) + (sigma*z)/w1;
    end
end

x0T = x0';
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);
Num = LogLikePositive(proposal) + proposalDist(x0T(:)');
Den = LogLikePositive(x0T(:)) + proposalDist(proposal');
alpha = Num - Den;
u =log(unifrnd(0,1,1));
if u  <= alpha
    retval = proposal;
else
    retval = x0;
end


end

