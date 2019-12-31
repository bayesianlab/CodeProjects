function [factor,maxLag] = inefficiencyFactors(column, M)
ineff = 0;
T = size(column,1);
maxLag =0;
for m = 1:M
    maxLag=maxLag+1;
    x=column(1:T-m);
    y=column((m+1):end);
    rho = corr([x,y]);
    ineff = ineff+rho(1,2);
    if abs(rho(1,2)) < .05
        break
    end
end
factor=1+2*ineff;
end

