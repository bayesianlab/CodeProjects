function [] = crbFactor(lb, upb, mles, mleVar, yt, Xt,...
    Sigma, ahat, Sinv, N)
sample = tmultnormrnd(lb,upb, mles, mleVar,N, zeros(length(mles),1));
bn = floor(.1*N);
sample = sample(bn:N,:);
[z, fz] = chibml(lb, upb,mles,mleVar,sample, N, bn);
z = z';
fz = fz';
[rA, cA] = size(ahat);
[~ , cX] =size(Xt);
[~, cS] = size(Sigma);
Aindex = 1:rA*cA;
Bindex = rA + 1:rA + cX;
Sindex = rA + cX + 1:rA + cX + cS;
Asample = z(:, Aindex);
Bsample = z(:, Bindex);
Ssample = z(:,Sindex);
[TK, ~] = size(yt);
[K, ~ ] = size(Sigma);
T = TK/K;
yt = reshape(yt, K,T);
mut = reshape(Xt*Bsample', K,T);
LL = factorModelLogLikelihood(yt,mut, diag(Ssample), Asample', Sinv);
igpdf = 0;
for j = 1:cS
    igpdf = igpdf + loginvgampdf(Ssample(j), 5, 10);
end
logml = LL+logmvnpdf(Bsample, zeros(1,length(Bsample)),10*eye(length(Bsample)))...
    +igpdf-log(prod(fz));
fprintf('Crb Log marginal likelihood %f\n', logml)
end

