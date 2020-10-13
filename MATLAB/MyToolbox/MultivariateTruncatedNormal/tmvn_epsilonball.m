function [draws] = tmvn_epsilonball(newCut, N)
draws = zeros(N,1);
for i = 1:N
    if newCut > 5
        draws(i)=drawRobertTruncated(newCut);
    else
        draws(i)=oneSidedTruncatedNormal(newCut);
    end     
end
end

