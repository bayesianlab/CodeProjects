function [proposal] = AmF(x0, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft, FtPrecision,  Imat, FactorIndices, RestrictedIndices, InfoCell, options)

[rows, cols] = size(x0);
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
n = rows*cols;
nFactors = length(RestrictedIndices);
LL = @(guess) -Amll(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft, FtPrecision, Imat, FactorIndices);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
m = themean';
vecm = m(:);
V = Hessian\speye(n);
proposal = vecm + chol(V, 'lower')*normrnd(0,1, n,1)./w1;

for u = 1:nFactors
    check = RestrictedIndices(u);
    if proposal(check) < 0
        sigma = sqrt(V(check,check));
        alpha = -(themean(1)*w1)/sigma;
        z = truncNormalRand(alpha, Inf,0, 1);
        restricteddraw = themean(check) + (sigma*z)/w1;
        proposal(check) = restricteddraw;
    end
end
proposal = proposal';
proposal = reshape(proposal, rows,cols);



end

