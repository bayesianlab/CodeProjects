function [ xNew, variances ] = logit_Steepest_Descent( guess, X,y, step,...
    tolerance )
cnt = 0;
xOld = guess;
xNew = 0;
alpha = step;
ep = tolerance;
[r,c] = size(X);
df= logitD(xOld, X, y) ;
xNew = xOld + alpha*df;
error = abs(norm(xNew - xOld)/norm(xOld));
cnt = 0;
maxIt = 10000;
while cnt < maxIt &&  error > ep
    cnt = cnt + 1;
    df= logitD(xOld, X, y) ;
    xNew = xOld + alpha*df;
    error = abs(norm(xNew - xOld)/norm(xOld));
    xOld = xNew;
    cnt = cnt + 1;
end

fisherInfo = -(logitDD(xNew, X, y));
inverseFisher = inv(fisherInfo);
variances = sqrt(diag(inverseFisher));

str0 = sprintf('MLE Steepest Descent Method: %.4f \n', xNew);
str1 = sprintf('Iterations: %i \n', cnt);

disp(str0)
disp(str1)
end



