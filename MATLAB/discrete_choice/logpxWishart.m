function [pdfval] = logpxWishart(D, R, m, S)
% unnormalized
[rr, ~] = size(S);
% exponentOnD = .5*(m + 3*rr -3);
exponentOnD = .5*m - 1;
exponentOnR = .5*(m - rr - 1);
logdetR = exponentOnR*logdet(R);
logdetD = exponentOnD*(sum(log(diag(D))));
Dhalf = D.^.5;
traceInvSDRD = -.5*trace(S\(Dhalf*R*Dhalf));
pdfval = logdetR + logdetD + traceInvSDRD;
end

