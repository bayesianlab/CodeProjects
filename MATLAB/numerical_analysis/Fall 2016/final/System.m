function [ z ] = System( X_0, alpha )
z(1,1) = F1(X_0, alpha);
z(2,1) = F2(X_0, alpha);
end

