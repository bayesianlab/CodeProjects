function [rn] = robertBelow(a,mu,sigma)
alpha = (a - mu) / sigma;
optimal =  (alpha + (alpha^2 + 4)^(.5))*.5;
LIMIT = 100;
lim=0;
while lim <= LIMIT
    lim = lim+1;
    z = shiftedExponentialDist(optimal, alpha);
    lrho_z = -.5*((z-optimal)^2);
    lu = log(unifrnd(0,1));
    if lu < lrho_z
        z = mu + sigma*z;
        rn = z;
        return
    else
    end
end
end

