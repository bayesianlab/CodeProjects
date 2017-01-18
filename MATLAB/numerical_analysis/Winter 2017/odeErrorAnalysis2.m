function [ order ] = odeErrorAnalysis2( sims, h, tSpan, yInit,  approxFnq)
[nEqns, ~] = size(yInit);
error = zeros(sims,nEqns);
order = zeros(sims-1, 2);
options = odeset('RelTol', 1e-10);
for i = 1:sims
    approx = runge4(tSpan, yInit, approxFnq, h);
    if approx == -1
        break
    end
    [~, trueFnqVals] = ode113(@dVanDerPol, approx(:,1), yInit, options);
    error(i, :) = max(abs(approx(:, 2:(nEqns + 1)) - trueFnqVals));
    if i >= 2
        order(i, 1) = h;
        order(i,2) = log2(error(i-1)/error(i));
        h = h / 2;
    end
end
order = order(3:sims, :);
end

