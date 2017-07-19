function [ rv ] = shiftexprnd(mu, shift, N)
rv = (shift*mu - (log(exp(mu*shift) - unifrnd(shift,1,N,1)))) ./ mu;
end

