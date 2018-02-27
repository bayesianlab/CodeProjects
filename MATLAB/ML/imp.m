function [logml] = imp(a,b,mu,Sigma,y, X, N, burnin, b0,B0,a0,d0)
[J,~] = size(Sigma);

C = chol(Sigma, 'lower');
[sample, logpdf]= tmultnormrndEta(a,b,mu,Sigma,N);
sample = sample(burnin:N, :);
[N, ~]= size(sample);

beta = sample(:,2:J);
sigmasqd = sample(:,1);
like = lrLikelihood(y,X,beta',sigmasqd);
lmvn = logmvnpdf(beta', mu(2:J), 1000*B0);
lig = loginvgampdf(sigmasqd, a0,d0)';
logml = pdfavg(like)+pdfavg(lmvn)+pdfavg(lig)-pdfavg(logpdf);
dispstring = ...
    'Log Likelihood %f  Log MVNPDF %f Log InvGammaPdf %f \n Log mean product Kernel %f\n';
fprintf(dispstring, pdfavg(like),pdfavg(lmvn),pdfavg(lig),pdfavg(logpdf))
fprintf('Imp Log marginal likelihood %f\n', logml)
end

