function [ bool ] = checkX( x )
if x > 1
    bool = 0;
elseif x < 0
    bool = 0; 
else
    bool = 1;
end

