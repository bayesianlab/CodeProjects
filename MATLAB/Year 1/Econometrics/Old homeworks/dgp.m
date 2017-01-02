function [yData] = dgp(xData, beta,  error)
% xData, beta and error are column vectors. Data Generating
% Process for y. 
yData = xData*beta + error;
end