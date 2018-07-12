function [meanb, meana, meangamma, meanfactor, ahat, Ahat,Sinv] = ...
    factorModelGibbs(y, X, initSigma, theta0, Theta0, initGamma,...
    initFactorVar, inita, sims, burnin)

% sample b
% sample a f
%% sample a
%% sample f
% sample variance

% Priors and dimensions
[N, ~] = size(y);
[arows, acols] = size(inita);
[J,~] = size(initSigma);
T = N/J;
IT = eye(T);
[nFacs, nColsGamma] = size(initGamma);
IR = eye(nFacs);
df = 10;
gammaVu = 5;
gammaD = 10;
gammaAlphaUpdate = .5*(gammaVu + T);
gammaPriorVar = eye(length(initGamma))*10;
gammaPrior = zeros(length(initGamma),1);
gammaPriorsProduct = gammaPriorVar * gammaPrior;
invTheta0 = inv(Theta0);
priorols = invTheta0*theta0;


stoB = zeros(sims, length(theta0));
stoA = zeros(sims,length(inita));
stoFactor = zeros(sims, T);
stoSigma = zeros(sims, J);
stoGamma = zeros(sims, nFacs*nColsGamma);
fprintf('Begin Gibbs Sampling\n')
notj = nonSquareNotj(arows,acols);

us = log(unifrnd(0,1,sims,1));
for i = 1 : sims
    [S, Sinv] = createFactorBandedDiag(initGamma, initFactorVar, IT, T, nFacs);
    Omega = kron(IT, initSigma);
    A = kron(IT, inita); 
    V = Omega + A*Sinv*A';
    Theta = inv(invTheta0 + X'*inv(V)*X);
    theta = Theta*priorols + Theta*X'*inv(V) * y;
    beta = mvnrnd(theta,Theta, 1);
    stoB(i,:) = beta;
    mu = X*beta';
    [aProposal,proppdfstar, proppdf, LLstar, LL, ahat, Ahat] = ...
        drawaProposal(y, mu, initSigma,Sinv,inita,df, J,T);
    alpha = min(0, LLstar + proppdf - (LL + proppdfstar));
    if us(i) <= alpha
        inita = aProposal;
        stoA(i, :) = inita';
    else
        stoA(i,:) = inita';
    end
    F = inv(S + kron(IT, inita'*inv(initSigma)*inita));
    psi = F*kron(IT, inita'*inv(initSigma))*(y-mu);
    factor = mvnrnd(psi, F);
    stoFactor(i,:) = factor;
    yhat = reshape(mu, J,T) + inita*factor;
    for j = 1 : J
       e = yhat(j,:)*yhat(j,:)';
       omegaii(j) = 1/gamrnd(gammaAlphaUpdate, 1/(.5*(gammaD + e)));
       stoSigma(i, :) = omegaii;
       initSigma = diag(omegaii);
    end
    Dhat = inv(gammaPriorVar + factor(1:T-1)*factor(1:T-1)');
    g = Dhat*gammaPriorsProduct + Dhat*factor(1:T-1)*factor(2:T)';
    gammaProposal = normrnd(g,Dhat,1);
    alphaGamma = min(0,logmvnpdf(factor(1),zeros(nFacs,1),...
        inv(1-initGamma)*initFactorVar) - ... 
       logmvnpdf(factor(1), zeros(nFacs,1),...
       inv(1-gammaProposal)*initFactorVar));
   if us(i) <= alphaGamma
       initGamma = gammaProposal;
       stoGamma(i, :) = reshape(gammaProposal, 1, nFacs*nColsGamma);
   else
       stoGamma(i, :) = reshape(initGamma, 1, nFacs*nColsGamma);
   end
end
meanfactor = mean(stoFactor);
meangamma = mean(stoGamma);
meansigma = mean(stoSigma);
meanb = mean(stoB);
meana = mean(stoA);
end
