function [ summ ] = ordinal_LL( beta, sigmaSqd, X,y )
[r,c] = size(beta);
if r < c
    beta = beta'
end
sigma = sqrt(sigmaSqd);
xTimesB = X*beta;
[ro, co]= size(y);
summ = 0;
for i = 1:ro
    if y(i) == 1
        summ = summ + log(normcdf(-xTimesB(i)/sigma));
    elseif y(i) == 2
        secondCut = normcdf( (1-xTimesB(i))/sigma ) - normcdf(-xTimesB(i)/sigma);
        summ = summ + log(secondCut);
    else
        summ = summ + log(1 - normcdf( (1 - xTimesB(i)))/sigma );
    end
 
end
summ = -summ;
end
