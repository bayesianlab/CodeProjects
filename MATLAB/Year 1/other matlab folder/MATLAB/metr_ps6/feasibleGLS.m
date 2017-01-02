function [ beta_fgls ] = feasibleGLS( x, y )
betaHats = betaOLS(x,y);
fits = x*betaHats;
resids = y - fits;
residsSqd = resids.^2;
omegaInv = inv(diag(residsSqd));
beta_fgls = inv(x'*omegaInv*x) *(x'*omegaInv*y);
end

