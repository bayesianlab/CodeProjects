function [rn] = leftTruncation(a)
optimal =  (a + (a^2 + 4)^(.5))*.5;
maxiterations = 0;
LIM = 100000;
while maxiterations < LIM 
    z = shiftedExponentialDist(optimal, a);
    lu = log(unifrnd(0,1));
    lrho_z = -.5*((z-optimal)^2);
    if lu < lrho_z
        rn = z;
        return
    else
        maxiterations = maxiterations + 1;
    end    
end
fprintf('Error in leftTruncation\n')
end
