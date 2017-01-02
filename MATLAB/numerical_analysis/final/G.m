function [ z ] = G( X, alpha)
z(1,1) = FA(X,alpha);
z(2,1) = FB(X, alpha);
end

