function [olsEst, resids] = betaOLS(X,y)
% Returns nx1 matrix n is length of data input.
% Include a column of 1's for constant. 
% olsEst(1,1) = b_0 and olsEst(2,1) = b_ols
olsEst = inv(X'*X) * (X'* y);

resids = y - X*olsEst;
end
