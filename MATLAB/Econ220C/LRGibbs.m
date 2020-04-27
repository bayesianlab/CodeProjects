function [storeBeta, storeSig2] = LRGibbs(y,X, b0, B0, ig_parama0, ig_paramb0, Sims, burnin)
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
storeSig2 = zeros(Runs);
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
end

