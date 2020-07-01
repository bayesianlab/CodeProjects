function [lam2] = nextlambda(lam0, lam1, dflam0, dflam1,flam0, flam1)
d1 = dflam0 + dflam1 - 3*(flam0 - flam1)/(lam0-lam1);
d2 = ((d1^2) - dflam0*dflam1)^(.5);
lam2 = lam1 - (lam1-lam0)*( (dflam1 + d2 - d1)/(dflam1 - dflam0 + 2*d2) );
end

