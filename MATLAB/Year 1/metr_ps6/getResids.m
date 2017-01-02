function [ residuals] = getResids( xVec, yData, olsEstm )
% Returns residuals
residuals = yData - xVec*olsEstm;



end

