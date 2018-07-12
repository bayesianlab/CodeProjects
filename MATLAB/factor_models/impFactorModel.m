function [] = impFactorModel(lb, upb, mles, mleVar, yt, Xt, Sigma, ahat,...
    Sinv, N)
[sample, logpdf]= tmultnormrndEta(lb,upb,mles,mleVar,N);
[rA, cA] = size(ahat);
[~ , cX] =size(Xt);
[~, cS] = size(Sigma);
Aindex = 1:rA*cA;
Bindex = rA + 1:rA + cX;
Sindex = rA + cX + 1:rA + cX + cS;
Asample = sample(:, Aindex);
Bsample = sample(:, Bindex);
Ssample = sample(:,Sindex);
[TK, ~] = size(yt);
[K, ~ ] = size(Sigma);
T = TK/K;
yt = reshape(yt, K,T);
LL = zeros(N,1);
igpdf = zeros(N,1);
b0 = zeros(cX, 1)';
B0 = 10*eye(cX);
bprior = zeros(N,1);
for i = 1 : N
    bprior(i) = logmvnpdf(Bsample(i, :), b0, B0); 
    mut = Xt*Bsample(i, :)';
    mut = reshape(mut, K,T);
    LL(i) = factorModelLogLikelihood(yt,mut,diag(Ssample(i,:)),...
        Asample(i,:)', Sinv);
end
for j = 1 : cS
    igpdf = igpdf + loginvgampdf(Ssample(:,j)', 5, 10);
end
logml = pdfavg(LL)+pdfavg(bprior)+pdfavg(igpdf)-pdfavg(logpdf);
fprintf('Imp Log marginal likelihood %f\n', logml)
end




