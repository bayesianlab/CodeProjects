function [] = factorModelGibbs(y,X, initG, factorVar)

% sample b
% sample a f
%% sample a
%% sample f
% sample variance
QuadForm = initG' * factorVar * initG
onePgamma2 = 1 + gamma2;
OffDiag = [(onesT(1:T)*-gamma)']';
MainDiag = [1, (onesT(2:T-1).*onePgamma2)', 1]';
F0 = full(spdiags([OffDiag, MainDiag, OffDiag], [-1,0,1], T, T));
sigma2F0inv = inv(F0);
end

