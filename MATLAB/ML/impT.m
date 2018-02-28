function [] = impT(a,b,mu,Sigma, nu,...
    y, X, N, b0,B0,a0,d0)
[J,~] = size(Sigma);
L = chol(Sigma, 'lower');
precision = inv(Sigma);
Hxx = diag(precision);
HxxInv = Hxx.^(-1);
lowerLdiag = diag(L);
offDiagonals = tril(L, -1);

[sample, logpdf]= ghkT(a,b,mu,Sigma, nu, N);
beta = sample(:,2:J);
sigmasqd = sample(:,1);
like = lrLikelihood(y,X,beta',sigmasqd);
lmvn = logmvnpdf(beta', mu(2:J), 1000*B0);
lig = loginvgampdf(sigmasqd, a0,d0)';
logml = pdfavg(like)+pdfavg(lmvn)+pdfavg(lig)-pdfavg(logpdf);
dispstring = ...
    'Log Likelihood %f  Log MVNPDF %f Log InvGammaPdf %f\n Log mean product Kernel %f\n';
fprintf(dispstring, pdfavg(like),pdfavg(lmvn),pdfavg(lig),pdfavg(logpdf))
fprintf('Imp Log marginal likelihood %f\n', logml)
end

