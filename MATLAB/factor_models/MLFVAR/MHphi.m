function [condLike] = MHphi(Y, SigmaLower, phi, delta0, Delta0)
% This is in vectorized form
% ystar comes in as a column vector for 
% conformity premultiplied by the initial distribution
% phi is a column
LLpart2 =-log(det(SigmaLower)) + (-.5*(Y'*Y));
LLpart3 = logmvnpdf(phi', delta0, Delta0);
condLike = LLpart2+LLpart3;
end

