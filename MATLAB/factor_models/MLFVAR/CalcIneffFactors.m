function [factors, largest] = CalcIneffFactors(MCMCOutput, M)
[R,~] = size(MCMCOutput);
factors=zeros(R,1);
largest = zeros(R,1);
for r = 1:R
    Row = MCMCOutput(r,:);
    [factors(r), largest(r)] =inefficiencyFactors(Row', M);
end
end

