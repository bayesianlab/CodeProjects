function [ f,g ] = test(b,pLL, gpLL)
f = pLL(b);
if nargout>1
    g = gpLL(b);
end
    


end

