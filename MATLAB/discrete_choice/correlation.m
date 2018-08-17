function [ r ] = correlation( corrparams )
n= length(corrparams);
r = eye(n+1);
rowcount = 0;
for i = 1:n+1
    rowcount = rowcount + 1;
    for j = 1:n+1
        if j < i
            r(i,j) = prod(corrparams(j:i-1));
        end
    end
    rowcount = 0;
end

r=triu(r',1) + r;
end

