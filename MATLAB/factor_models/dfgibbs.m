function [ output_args ] = dfgibbs(y,X, a,g, F0,SigmaDiag, Sdiag,...
    omega2, b0,B0, apriormean, apriorCov, Sims)
K = length(SigmaDiag);
T = length(y)/K;
% set up F matrix, the precision
h = [ones(T,1).*(-g), ones(T,1), ones(T,1).*(-g)];
p = full(spdiags(h,[-1,0],T,T));
S = ones(T,1).*omega2;
S = diag(S);
B0inv = B0\eye(size(B0,1));
F0 = p*S*p';
Sdiag = diag(F0);
FullSigma = diag(SigmaDiag);

F = F0 + kron(eye(T), [1;a]'*diag(SigmaDiag)*[1;a]);
lowerCholF = chol(F,'lower');
lowerCholF'*lowerCholF


amean = a
for i = 1:Sims
    [b,B] = updateBetaPriors(y,X,[1;a],omega2,F0, SigmaDiag, b0,B0inv);
    b1 = b + chol(B,'lower')*normrnd(0,1,length(b0),1);
    mu = X*b;
    derivll = @(guess)DmarginalLogLikelihood(y,mu,FullSigma,guess,Sdiag);
    
    [a, amean, ~] = mhStepForA(y,mu,FullSigma,Sdiag,derivll, amean, ...
        apriormean,apriorCov, 15);
    
    
    
    
end

