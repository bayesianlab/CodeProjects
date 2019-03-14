function [d] = truncatedAbove(b,mu,sigma)
beta = (b-mu)/sigma;
if beta < -7
d = -truncatedBelow(-b,-mu,sigma);
else
    d = -robertBelow(-b,-mu,sigma);
end
end

