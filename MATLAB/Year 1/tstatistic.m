function [ tStat, tCrit ] = tstatistic( regOut, null, ci, obsLessDegFree, altEnum )
% Alt Enum: One sided v Two sided boolean 

if isrow(null) == 1
    null = null';
end

tStat = (regOut(:,1) - null) ./ regOut(:,2);

if nargin > 3
    if altEnum == 1
        tCrit = tinv(ci, obsLessDegFree);
    else
        tCrit = tinv(ci/2, obsLessDegFree);
    end
else
    tCrit = tinv(ci/2, obsLessDegFree);
end
    




end

