function [ fy ] = loginvgampdf(y, alpha, beta )
C1 = -(alpha.*log(beta) + gammaln(alpha) );
C2 = -(alpha + 1) .* log(y);
C3 = -1./ (beta.*y);
fy = (C1 + C2 + C3)';
end
