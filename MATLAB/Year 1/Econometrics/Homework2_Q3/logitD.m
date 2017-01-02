function [ deriv ] = logitD( beta, X, y )
bigPhi = cdf('Logistic', X*beta,0,1 );
deriv = ((y - bigPhi))'*X;
deriv= deriv';


end

