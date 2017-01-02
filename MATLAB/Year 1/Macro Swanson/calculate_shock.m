function [ shock ] = calculate_shock( mat )
[height, width] = size(mat);
s33= mat(3,3);
e= [0,0,.25/s33]';
shock = (mat*e)';
    


end

