function [ solution ] = predictorCorrector(tRange, y0, fnq, Dfnq,  h, epsilon, maxIterations )
col = length(y0);
[initYt,~] = getInitialPoints(2, tRange(1), y0, fnq, h);
t = initYt(:, 1);
yN = initYt(2, 2:(col+1));
yNm1 = initYt(1, 2:(col+1));
c = 3;
yt = zeros(floor((tRange(2) - tRange(1)) / h), col);
time = zeros(floor((tRange(2) - tRange(1)) / h), 1);
yt(1,:) = y0;
yt(2, :) = yNm1;
yt(3, :) = yN;
time(1, 1) = tRange(1);
time(2:3,1) = t;
while t(2) < tRange(2)
    c = c + 1;
    yStar = yN' + (h*.5*(3*fnq(t(2), yN) - fnq(t(1), yNm1)));
    t(1) = t(2);
    t(2) = t(2) + h;
    yGuess = [yN;yStar'];
    yNp1 = implicitNewtonStep(t, yGuess, @bigF2, @dBigF2, fnq, Dfnq, 1,...
        h, epsilon, maxIterations);
    yt(c,:) = yNp1(2, :);
    time(c,:) = t(2);
    yN = yt(c,:);
    yNm1 = yt(c-1, :);
end
solution = [time, yt];

end

