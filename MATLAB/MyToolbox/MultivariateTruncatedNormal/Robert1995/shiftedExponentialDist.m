function [rn] = shiftedExponentialDist(alpha, shift, n)
rn = shift - (1/alpha)*log(1-unifrnd(0,1, n,1));
end

