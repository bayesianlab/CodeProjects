function [ z ] = system1( X )
z(1,1) = X(1,1).^2 + X(2,1).^2 - 25;
z(2,1) = X(1,1).^2 - X(2,1) - 2;
end

