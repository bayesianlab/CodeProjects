function [out1, out2] = invGammaMoments(a, b, varargin)
if nargin == 2
    out1=b/(a-1);
    out2 = (b^2)/( ((a-1)^2)*(a-2) );
elseif nargin ==3
    out1 = ((a^2)/b) + 2;
    out2 = a*(((a^2)/b) + 1);
end
        
    

end

