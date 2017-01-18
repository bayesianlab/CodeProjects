function [ z] = FA( X, alpha)
z = -alpha * X(1) + 0.07* (1- X(1))*exp(X(2)/(1+.05*X(2)));
end

