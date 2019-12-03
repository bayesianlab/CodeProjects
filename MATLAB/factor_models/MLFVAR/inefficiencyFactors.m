function [factor] = inefficiencyFactors(column, M)
ineff = 0;
T = size(column,1);

for m = 1:M
    x=column(1:T-m);
    y=column((m+1):end);
    rho = corr([x,y]);
    ineff = ineff+rho(1,2);
end
factor=1+2*ineff;
end

