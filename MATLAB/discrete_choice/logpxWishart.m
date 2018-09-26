function [pdfval] = logpxWishart(D, R, m, S)
% unnormalized
[rr, ~] = size(S);
exponentOnD = .5*m - 1;
exponentOnR = .5*(m - rr - 1);
sumlogD = sum(log(diag(D)));
logdetR = exponentOnR*logdet(R);
logdetD = exponentOnD*sumlogD;
Dhalf = D.^.5;
traceInvSDRD = -.5*trace(S\(Dhalf*R*Dhalf));
pdfval = logdetR + logdetD + traceInvSDRD;
end

