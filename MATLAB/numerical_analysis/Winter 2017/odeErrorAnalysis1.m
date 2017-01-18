function [ order ] = odeErrorAnalysis1( sims, h, tSpan, yInit,  approxFnq, trueFnqVals)
[nEqns, ~] = size(yInit);
error = zeros(sims,nEqns);
order = zeros(sims-1, 2);
for i = 1:sims
    approx = runge4(tSpan, yInit, approxFnq, h);
    error(i, :) = max(abs(approx(:, 2:nEqns + 1) - trueFnqVals(approx(:,1))));
    if i >= 2
        order(i,1) = h;
        order(i,2) = log2(error(i-1)/error(i));
        h = h / 2;
    end
end
order = order(3:sims, :);
end

