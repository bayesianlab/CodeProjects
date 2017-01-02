function [ mleBeta, variances ] = probit_Newton_Method( beta, X, y, errTol )
cnt = 0;
xOld = beta;
xNew = 0;
maxCount = 50000;
ep = errTol;
cnt = 0;
[r,c] = size(X);
xNew = xOld - inv(ddProbit(xOld, X,y)) * dprobit(xOld, X,y);
error = abs(norm(xNew - xOld)/norm(xOld));

while  cnt < maxCount && error > ep
    cnt = cnt + 1;
    xNew = xOld - inv(ddProbit(xOld, X,y)) * dprobit(xOld, X,y);
    error = abs(norm(xNew - xOld)/norm(xOld));
    xOld = xNew;
end
fisherInfo = -( ddProbit(xNew, X, y));
inverseFisher = inv(fisherInfo);
variances = sqrt(diag(inverseFisher));
str = sprintf('\n');
disp(str)
str1 = sprintf('MLE Probit Newton-Raphson Method: %.4f\n ', xNew);
str2 = sprintf('Iterations %i\n', cnt );
disp(str1)
disp(str2)

mleBeta = xNew;
end

