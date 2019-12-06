function [ll] = LinRegLL(beta, y, x, sig2)
vals = y-(x*beta);
N=length(y);
ll = -(.5*N)*log(2*pi*sig2) - (.5*((vals'*vals)/sig2));
end

