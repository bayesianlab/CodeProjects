function [factors] = CalcIneffFactors(MCMCOutput, M)
[R,~] = size(MCMCOutput);
factors=zeros(R,1);
for r = 1:R
    Row = MCMCOutput(r,:);
    factors(r) =inefficiencyFactors(Row', M);
end
end

