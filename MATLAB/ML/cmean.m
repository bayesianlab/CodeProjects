function [cmu] = cmean(mu, Hxx, Hxy, xNotj, muNotj)
if isrow(Hxy)
    Hxy = Hxy';
end
cmu = mu - ((1/Hxx)*Hxy'*(xNotj - muNotj));
end

