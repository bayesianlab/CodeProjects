function [pdfval] = logpxWishart(D, R, m, S)

[rr, ~] = size(S);
B = -0.5*m*logdet(S)-0.5*m*rr*log(2)-logmvgamma(0.5*m,rr);
exponentOnD = .5*m - 1;
exponentOnR = .5*(m - rr - 1);
sumlogD = sum(log(diag(D)));
logdetR = exponentOnR*log(det(R));
logdetD = exponentOnD*sumlogD;
Dhalf = D.^.5;
traceInvSDRD = -.5*trace(S\(Dhalf*R*Dhalf));
pdfval = B + logdetR + logdetD + traceInvSDRD;
end

