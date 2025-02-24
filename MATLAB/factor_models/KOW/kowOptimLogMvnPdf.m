function [pval] = kowOptimLogMvnPdf(demeanedy, Precision)
[A, p] = chol(Precision, 'lower');
if p ~= 0
    [~,D] = eig(Precision);
    d = diag(D);
    d(d <= 1e-3) = 1e-3;
%     [~,DD, ~] = svd(Precision);
    logdetPre = sum(log(d));
else
    logdetPre=  2*sum(log(diag(A)));
end
K = size(demeanedy,1);
const = -0.5 * K * log(2*pi);

pval = const + .5*logdetPre -.5*demeanedy'*Precision*demeanedy;

end

