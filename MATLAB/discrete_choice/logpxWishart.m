function [pdfval] = logpxWishart(D, R, m, S)
% unnormalized
[rr, ~] = size(R);
exp1 = .5*(m - rr - 1);
exp2 = .5*(m + rr - 3);
logdetR = exp1*log(det(R));
detD = exp2*log(prod(diag(D)));
invSDRD = trace(-.5*inv(S)*D*R*D);
pdfval = logdetR + detD + invSDRD;
end

