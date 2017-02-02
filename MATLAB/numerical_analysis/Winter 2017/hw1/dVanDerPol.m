function [ z ] = dVanDerPol( t, y )
z = [y(2) ; (1 - y(1)^2)*y(2) - y(1)];
end

