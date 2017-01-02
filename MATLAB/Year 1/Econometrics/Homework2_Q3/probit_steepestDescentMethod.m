function [ xNew, variances ] = probit_steepestDescentMethod( startGuess,...
    X, y, alpha, errorTolerance)
cnt = 0;
xOld = startGuess;
xNew = 0;
alpha = alpha;
ep = errorTolerance;
[r,c] = size(X);
df= dprobit(xOld, X, y) ;
xNew = xOld + alpha*df;
error = abs(norm(xNew - xOld)/norm(xOld));
cnt = 0;
maxIt = 10000;
while cnt < maxIt &&  error > ep
    cnt = cnt + 1;
    df= dprobit(xOld, X, y) ;
    xNew = xOld + alpha*df;
    error = abs(norm(xNew - xOld)/norm(xOld));
    xOld = xNew;
    cnt = cnt + 1;
end

fisherInfo = -(ddProbit(xNew, X, y));
inverseFisher = inv(fisherInfo);
variances = sqrt(diag(inverseFisher));

str0 = sprintf('MLE Steepest Descent Method: %.4f \n', xNew);
str1 = sprintf('Iterations: %i \n', cnt);

disp(str0)
disp(str1)
end

