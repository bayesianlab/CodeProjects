function [gamma] = CutPoints(delta)
n = length(delta);
gamma = zeros(n+2,1);
gamma(1) = 0;
for i = 1:n
    gamma(i+1) = sum(exp(delta(1:i)));
end
gamma(n+2) = Inf;
end

