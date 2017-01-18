function [ z] = FB( X, alpha)
z = -alpha*X(2) + 1.4*(1-X(1))*exp(X(2)/(1+.05*X(2))) -1.975*X(2);
end

