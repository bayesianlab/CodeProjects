function [ cmu ] = conditionalMeanMVN(mu, Hxx, Hyx, xNotj, muNotj)
% expect mu as a row vector
[~, c1] = size(xNotj);
[~, c2] = size(muNotj);
if c1 ~= c2
    xNotj = xNotj';
end
cmu = mu - ((1/Hxx)*Hyx*(xNotj' - muNotj'));
end

