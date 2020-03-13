function [ draw ] = oneSidedTruncatedNormal(lowerCut)
Fa = normcdf(lowerCut);
q1 = 1-Fa;
draw = norminv(Fa +  unifrnd(0,1)*q1);
end
