function [p] = stpdf(x,df)
ex = .5*(df+1);
cg = gamma(ex)/gamma(.5*df);
cpi = sqrt((1/(df*pi)));
log(cpi)
p=cg*cpi*(1 + (1/df) *(x^2))^(-ex);
end