function [ fy] = invgampdf(y, alpha, beta )
cons = 1/((beta^alpha)*gamma(alpha));
fy = ( cons.* (y.^(-(alpha+1))) .* exp(-1./(beta.*y)) )';
end

