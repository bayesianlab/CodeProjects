function[ coefs ] = dividedDifferences(X_is, evaledPoints)
n = length(evaledPoints);
store = zeros(n, n);
store(1:n,1) = evaledPoints;
coefs = zeros(n,1);
coefs(1) = evaledPoints(1);
eps = 10^(-18);
EPS = 10^18;
for j= 2:n
    for i=j:n
        num = store(i,j-1) - store(i-1, j-1);
        den = (X_is(i) - X_is(i - j + 1))^(-1);
        store(i,j) = num*den;
        if i == j
            coefs(i) = store(i,j);
        end
    end
end
end