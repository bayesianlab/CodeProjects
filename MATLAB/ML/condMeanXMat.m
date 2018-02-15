function [cmu] = condMeanXMat(mu, Hxx, Hyx, xNotj, muNotj)
cmu = mu - ((1/Hxx)*Hyx'*(xNotj - muNotj));
cmu = cmu';
end

