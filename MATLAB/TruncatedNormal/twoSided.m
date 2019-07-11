function [rn] = twoSided(a,b)
maxiterations = 0;
LIM = 10000;
while maxiterations < LIM
   z = unifrnd(a,b);
   lu = log(unifrnd(0,1));
   if (a<0) && (0<b)
       rho_z = -.5* z^2;
       if lu < rho_z
           rn = z;
           return
       else
           maxiterations = maxiterations + 1;
       end
   elseif b < 0
       rho_z = ((b^2) - (z^2))*.5;
       if lu < rho_z
           rn= z;
           return
       else
           maxiterations = maxiterations + 1;
       end
   else
       rho_z = .5*(a^2 - z^2);
       if lu < rho_z
           rn=z;
           return
       end
   end    
end
fprintf("Error in two sided truncation\n")
end

