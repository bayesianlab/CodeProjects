function [storeBeta, storeSig2, yf, ml] = LRGibbs(y,X, b0, B0, ig_parama0,...
    ig_paramb0, Sims, burnin, forecast, Xf)
%% LRGibbs 
% X is  expected to have T rows and K columns

[T, K] = size(X);
IK = eye(K);
 
B0inv = B0\eye(K);
ig_parama = T + ig_parama0;

XpX = X'*X;
Xpy = X'*y;

sigma2 = 1;

Runs = Sims - burnin; 
storeBeta = zeros(K, Runs);
storeSig2 = zeros(1,Runs);
[frows, fcols] = size(Xf);
yf = zeros(frows,Runs);
for sim = 1:Sims
    % Update beta parameters (mean, variance)
    B1 = ( (XpX/sigma2) + B0inv )\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    b1update = b1 + (chol(B1, 'lower') * normrnd(0,1,K,1));
    
    % Update sigma2
    e = y - X*b1update;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigma2 = 1/gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
    
    % Store all updates after burnin
    if sim > burnin
        postIndex = sim - burnin; 
        storeBeta(:, postIndex) = b1update;
        storeSig2(:, postIndex) = sigma2;
    end
end

if forecast == 1
    for r = 1:Runs
        b = storeBeta(:,r);
        s2 = storeSig2(:,r);
        yf(:,r) = Xf*b + chol(s2, 'lower').*normrnd(0,1,frows,1);
    end
end

ReducedRuns = Sims-burnin;
betaStar = mean(storeBeta,2);
piBetaStar = zeros(1,ReducedRuns);
sigj = zeros(1,ReducedRuns);
for r = 1 : ReducedRuns
    sigma2 = storeSig2(r);
    B1 = ( (XpX/sigma2) + B0inv )\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    piBetaStar(r) = logmvnpdf(betaStar', b1', B1);
    
    % Update sigma2
    e = y - X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigj(r) = 1/gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
end
piBetaStar = mean(piBetaStar);
e = y-X*betaStar;
ig_paramb = (ig_paramb0 + (e'*e));
sigStar = mean(sigj);
piSigStar = logigampdf(sigStar, ig_parama, ig_paramb);
like = logmvnpdf(e'./sigStar, zeros(1,T), eye(T));
priors = logmvnpdf(betaStar, b0', B0) + logigampdf(sigStar, .5*ig_parama0, (.5*ig_paramb0));
ml = like + priors - (piSigStar + piBetaStar);
end
