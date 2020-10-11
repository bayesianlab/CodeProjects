function [storeBeta, storeSigma2, ml] = RestrictedLR_Gibbs(Constraints, y,X,...
    b0, B0, ig_parama0, ig_paramb0, Sims, burnin, samplerType, mltype)
%% LRGibbs
% X is  expected to have T rows and K columns
% mltype: 1 Chibs
% 2 CRT
%
[T, K] = size(X);
IK = eye(K);
B0inv = B0\eye(K);
ig_parama = T + ig_parama0;
XpX = X'*X;
Xpy = X'*y;
sigma2 = 1;

Runs = Sims - burnin;
storeBeta = zeros(K, Runs);
storeSigma2 = zeros(1,Runs);
for sim = 1:Sims
    % Update beta parameters (mean, variance)
    B1 = ( (XpX/sigma2) + B0inv )\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    if samplerType == 1
    b1update=GibbsTMVN(Constraints, b1, B1, 1,0);
    elseif samplerType == 2
        b1update=arkSampler(Constraints, b1, B1)
    end
    % Update sigma2
    e = y - X*b1update;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigma2 = 1/gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
    
    % Store all updates after burnin
    if sim > burnin
        postIndex = sim - burnin;
        storeBeta(:, postIndex) = b1update;
        storeSigma2(:, postIndex) = sigma2;
    end
end


ReducedRuns = Sims-burnin;
% bMLE = XpX\Xpy;
% e = y - X*bMLE;
% sSqd = (e'*e)/T;
% thetaMLE = [sSqd; bMLE];
% invFisher = [(2*sSqd^2)/T, [0,0];[0;0], XpX\ (eye(K).*sSqd)];

%% ML Chibs method
if mltype == 1
    piBetaStar = zeros(K,ReducedRuns);
    sigj = zeros(1,ReducedRuns);
    
    rrbeta = zeros(K,ReducedRuns);
    betaj = storeBeta;
    betag = betaj;
    xtemp = zeros(K,1);
    sigma2j = storeSigma2;
    
    
    for k = 1 : K
        betaStar = mean(betaj,2);
        betag(1:k,:) = ones(length(1:k), ReducedRuns).*betaStar(1:k);
        betag(k+1:K,:) = betaj(k+1:K,:);
        sigma2g = sigma2j;
        for r = 1 : ReducedRuns
            if k < K
                sigma2 = sigma2g(r);
                xtemp = betag(:,r);
                B1 = ( (XpX/sigma2) + B0inv )\IK;
                b1 = B1 * ( (Xpy/sigma2) + B0inv*b0 );
                piBetaStar(k,r) = conditionaltmvnpdf(xtemp, b1, B1, Constraints, k);
                
                betaj = shortGibbsMVN(xtemp, b1, B1, Constraints, k+1);
                
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            else
                xtemp = betaStar;
                piBetaStar(k,r) = conditionaltmvnpdf(xtemp, b1, B1, Constraints, k);
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            end
        end
    end
    piBetaStar = sum(logAvg(piBetaStar));
    e = y-X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigmaStar = mean(sigma2j);
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = logmvnpdf(betaStar, b0', B0) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    
    ml = like + priors - (piSigStar + piBetaStar);
elseif mltype == 2
    betaStar = mean(storeBeta,2);
    x = zeros(K,1);
    sigmaStar = mean(storeSigma2);
    Kernel = zeros(K, ReducedRuns);
    for k = 1:K-1
        x(1:k) = betaStar(1:k);
        for r = 1 : ReducedRuns
            x(k+1:end) = storeBeta(k+1:end, r);
            Precision = ( (XpX/sigma2) + B0inv );
            B1 = Precision\IK;
            b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
            Kernel(k,r) = conditionaltmvnpdf(x, b1, B1, Constraints, k);
        end
    end
    x = betaStar;
    Precision = ( (XpX/sigma2) + B0inv );
    B1 = Precision\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    e = y-X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    
    Kernel(k,:) = conditionaltmvnpdf(x, b1, B1, Constraints, K);
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = logmvnpdf(betaStar, b0', B0) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    piBetaStar = logAvg(sum(Kernel,1));
    
    ml = like + priors - (piSigStar + piBetaStar);
end
end


