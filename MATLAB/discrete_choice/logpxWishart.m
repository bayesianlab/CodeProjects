function [pdfval] = logpxWishart(D, R, m, S)
% unnormalized
[rr, ~] = size(S);
exponentOnD = m + rr - 2;
exponentOnR = .5*(m - rr - 1);
logdetR = exponentOnR*log(det(R));
logdetD = exponentOnD*log(prod(diag(D).^2));
traceInvSDRD = -.5*trace(inv(S)*D*R*D);
pdfval = logdetR + logdetD + traceInvSDRD;
end

