function [ sol ] = implicitMethod1( tRange, y0, fnq, Dfnq, h, maxIterations, epsilon )
col = length(y0);
[yt, ~] = getInitialPoints(2, tRange(1), y0, fnq, h);
tPrevious = yt(:,1);
yPrevious = yt(:, 2:(1+col));
c = 0;
predictedYs =  zeros(floor((tRange(2) -tRange(1))/ h), col);
time = zeros(floor((tRange(2) -tRange(1))/ h), 1);
predictedYs(1:2, :) = yPrevious(:,:);
time(1:2, :) = tPrevious(:,1);
while tPrevious(2,1) < tRange(2)
    c = c +1;
    [yOut, ~] = getInitialPoints(1, tPrevious(2,1), yPrevious(2, :), fnq, h);
    tNew = yOut(:,1);
    yGuess = yOut(:,2:(1+col));
    ts = [tPrevious;tNew];
    ys = [yPrevious; yGuess];
    yOut = implicitNewtonStep(ts, ys, @bigF, @dBigF, fnq, Dfnq, 2, h, epsilon,...
        maxIterations);
    tPrevious = ts(2:3,1);
    yPrevious = yOut(2:3,1:col);
    predictedYs(c+2,:) = yOut(3,:);
    time(c+2,1) = tNew;
end
sol = [time, predictedYs];
end

