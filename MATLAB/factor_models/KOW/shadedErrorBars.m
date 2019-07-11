function [] = shadedErrorBars(xvals, mu, sigma, true)

upper = mu + 2*sigma;
lower = mu - 2*sigma;
Y = [upper, fliplr(lower)];
X = [xvals, fliplr(xvals)];
hold on
plot(xvals, true, 'black')
f = fill(X,Y, [0,0,0]);
set(f, 'facealpha',.1)
hold off
end

