function [condLike] = MHphi(yp,xp,beta, sigma2, ystar, Xstar, phi, Cinv)
% This is in vectorized form
% ystar comes in as a column vector for 
% conformity
% phi is a column
% C is not assumed to be correctly transposed when coming 
% in, it is transposed inside
lags = size(Cinv,1);
K=length(sigma2);
y1N = reshape( (Cinv'*yp)- (Cinv'*xp*beta),K,lags);
detpart = (-.5*lags).*2*sum(log(diag(Cinv)));
kernalpart = (-.5).*(y1N'*y1N)./(sigma2);
LLpart1 = detpart+kernalpart;
Y = ystar - Xstar*phi;
LLpart2 = (-.5*(Y'*Y)./sigma2);
LLpart3 = logmvnpdf(phi', zeros(1,lags), eye(lags));
condLike = LLpart1+LLpart2+LLpart3;
end

