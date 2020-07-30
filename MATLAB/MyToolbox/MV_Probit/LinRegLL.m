function [ll] = LinRegLL(beta, y, x)
vals = y-(x*beta);
N=length(y);
ll = -(.5*N)*log(2*pi) - (.5*((vals'*vals)));
end

