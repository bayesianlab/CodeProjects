function [rn] = shiftedExponentialDist(alpha, shift)
rn = shift - (log(1 - unifrnd(0,1))/alpha);
end

