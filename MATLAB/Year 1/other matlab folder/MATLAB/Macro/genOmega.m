function [ omega] = genOmega( expectedValue, g1, beta, power)
% Calculates omega
den = g1 * (1 - (beta * (expectedValue^power)));
omega = ((1/den)^(1/power)) - 1;
end

