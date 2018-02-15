function [ac] = autocor(y,lag)
if isrow(y)
    y = y';
end
[~,J] =size(y);
LY = lagvars(y,lag);
ac = corr(LY(:,:), LY(:,:));
ac = diag(ac, J);
end

