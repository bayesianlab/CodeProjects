function [pval] = kowOptimLogMvnPdf(demeanedy, Precision)
logdetPre=  2*sum(log(diag(chol(Precision))));
K = size(demeanedy,1);
const = -0.5 * K * log(2*pi);
pval = const + .5*logdetPre -.5*demeanedy'*Precision*demeanedy;

end

