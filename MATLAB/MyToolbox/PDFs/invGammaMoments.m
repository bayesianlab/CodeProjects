function [Ey, Vy] = invGammaMoments(a, b)
Ey=b/(a-1);
Vy = (b^2)/( ((a-1)^2)*(a-2) );
end

