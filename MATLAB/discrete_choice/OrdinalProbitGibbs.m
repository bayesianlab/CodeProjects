function [betaMat, gammaMat] = OrdinalProbitGibbs(delta,y,X,beta, h, nu, b0,B0, nSims,  ...
    lambda,tol,maxits)
fprintf('Ordinal Probit Gibbs\n')
Xbeta = X*beta;
XpX = X'*X;
B0inv = inv(B0);
B0invb0 = B0inv*b0;
Bbar = inv(XpX + B0inv);
[r,~] = size(Xbeta);
NumChoices = length(delta) + 2;
w = sqrt(chi2rnd(nu,nSims,1)/nu);
z = zeros(r,1);
logu = log(unifrnd(0,1,[nSims,1]));
betaMat = zeros(nSims, length(beta));
gammaMat = zeros(nSims, NumChoices);
for i = 1:nSims
    [deltaMle,Vmle, c] = MaxDelta(delta,y,X,beta, h, lambda, tol, maxits);
    Clow = chol(Vmle,'lower');
    deltap = deltaMle + Clow*normrnd(0,1,[NumChoices-2, 1])/w(i);
    alpha = min(0, (OpLogLikelihood(deltap,y,X,beta)  +...
        logtpdf(delta, deltaMle, Vmle, nu)) - ...
       (OpLogLikelihood(delta,y,X,beta) +...
       logtpdf(deltap, deltaMle,Vmle,nu)));
   if logu(i) < alpha
       gamma = CutPoints(delta);
       delta = deltap;
       gammaMat(i, :) = gamma'; 
   else
       gamma = CutPoints(delta);
       gammaMat(i,:) = gamma';
   end
    for k = 1:r
        if y(k) == 1
            a = -Inf;
        else
            a = gamma(y(k) - 1) - Xbeta(k);
        end
        z(k) = truncNormalRand(a, gamma(y(k)), Xbeta(k), 1);
    end
    bbar = Bbar*X'*z + Bbar*B0invb0;
    beta = mvnrnd(bbar',Bbar, 1)';
    betaMat(i, :) = beta';
end
end

