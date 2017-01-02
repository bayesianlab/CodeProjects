function [ xNew, ses, hessian ] = logit_NR_Method( guess, X,y, errTol )

cnt = 0;
xOld = guess;
xNew = 0;
maxCount = 50000;
ep = errTol;
cnt = 0;
[r,c] = size(X);
xNew = xOld - inv(logitDD(xOld, X,y)) * logitD(xOld, X,y);
error = abs(norm(xNew - xOld)/norm(xOld));

while  cnt < maxCount && error > ep
    cnt = cnt + 1;
    xNew = xOld - inv(logitDD(xOld, X,y)) * logitD(xOld, X,y);
    error = abs(norm(xNew - xOld)/norm(xOld));
    xOld = xNew;
end
hessian = logitDD(xNew, X, y);
fisherInfo = -( hessian );
inverseFisher = inv(fisherInfo);
ses = sqrt(diag(inverseFisher));
str = sprintf('\n');
disp(str)
str1 = sprintf('MLE Newton-Raphson Method: %.4f\n ', xNew);
str2 = sprintf('Iterations %i\n', cnt );
disp(str1)
disp(str2)

mleBeta = xNew;
end
