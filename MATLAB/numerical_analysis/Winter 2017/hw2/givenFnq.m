function [ z ] = givenFnq(t, y )
z(1,1) = -5*y(1) +3*y(2);
z(2,1) = 100*y(1) -301*y(2);
end

