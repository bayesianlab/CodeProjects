function [ pdfval ] = logInvWish( X, Scale, df )
k = size(Scale,1);
normcden = (log(2)*(.5*df*k)) + logMvGamma(.5*df, k);
normc = (logdet(Scale)*(.5*k)) - normcden;
pdfval = normc -.5*(df + k + 1)*logdet(X) - .5*(trace(X\Scale)); 
end

