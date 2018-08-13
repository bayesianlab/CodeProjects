clear;
clc;
M = 1000;
n = [10].^[1:5];
for i = 1:length(n)
    X = normrnd(0,1,1, n(i));
    Xbar = mean(X,2);
    for j = 1:length(Xbar)
       y = normrnd(Xbar(j), 1/sqrt(n(i)), 1, M) ;
       y = y(abs(y) > 0.01);
       [r,c] = size(y);
       if c ~=0
        sto(1,i) = quantile(normcdf(abs(y), 0, 1) - ...
            normcdf(0.01, 0, 1), .5);
        sto(2,i) = quantile(normcdf(abs(y), 0, 1) - ...
            normcdf(0.01, 0, 1), .75);
        sto(3,i) = quantile(normcdf(abs(y), 0, 1) - ...
            normcdf(0.01, 0, 1), .95);
       end
    end
end
plot(log10(n), sto')
xlabel('log(n)')
ylabel('Probability')
title('Quantiles of \Pi(\cdot)', 'Interpreter', 'tex')
legend('50%', '75%', '95%')
