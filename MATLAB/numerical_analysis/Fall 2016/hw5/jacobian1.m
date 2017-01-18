function [ z ] = jacobian1( X )
z(1,1) = 2*X(1,1);
z(1,2) = 2*X(2,1);
z(2,1) = 2*X(1,1);
z(2,2) = -1;
end

