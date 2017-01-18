function [ j ] = Jacobian(X_0, alpha)
j(1,1) = 2*X_0(1) ;
j(1,2) = 2*X_0(2);
j(2,1) = 1;
j(2,2) = -1;
end

