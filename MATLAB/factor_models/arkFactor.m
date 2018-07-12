function [] = arkFactor(lb, upb, mles, mleVar, yt, Xt,...
    Sigma, ahat, Sinv, N)
[sample]= tmultnormrndEta(lb,upb,mles,mleVar,N);
zs = mean(sample,1);
K = gibbsKernel(lb,upb, mles, mleVar, sample);
prop = log(mean(prod(K,2)));
[rA, cA] = size(ahat);
[~ , cX] =size(Xt);
[~, cS] = size(Sigma);
Aindex = 1:rA*cA;
Bindex = rA + 1:rA + cX;
Sindex = rA + cX + 1:rA + cX + cS;
Asample = zs(:, Aindex);
Bsample = zs(:, Bindex);
Ssample = zs(:,Sindex);
[TK, ~] = size(yt);
[J, ~ ] = size(Sigma);
T = TK/J;
yt = reshape(yt, J,T);
mut = reshape(Xt*Bsample', J,T);
LL = factorModelLogLikelihood(yt,mut, diag(Ssample), Asample', Sinv);
igpdf = 0;
for j = 1:cS
    igpdf = igpdf + loginvgampdf(Ssample(j), 5, 10);
end
logml = LL + logmvnpdf(Bsample, zeros(1,length(Bsample)),10*eye(length(Bsample)))...
    + igpdf - prop;
fprintf('Ark Log marginal likelihood %f\n', logml)
end

