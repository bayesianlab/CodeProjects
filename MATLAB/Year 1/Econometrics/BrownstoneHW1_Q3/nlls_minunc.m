function [ estimator,log_like, exitf, output, g, h,...
    standard_errors_betas ] = nlls_minunc( beta, X, y )
c_initial= beta; 

[estimator,log_like, exitf, output, g, h ]=...
    fminunc(@(c)nonLinearLeastSquares(c,X,y), c_initial);

[row, col] = size(X);
x_0 = cdf('Normal', X*estimator, 0, 1);
kronecker = kron(ones(1,col), x_0);
X_0 = kronecker.*X;
Q_0 = X_0'*X_0;
r= y - X*estimator;
resid_sqd = (1/row)*r'*r;
vc_mat = resid_sqd*inv(Q_0);
variances = diag(vc_mat);
standard_errors_betas = sqrt(variances);


end

