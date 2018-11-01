function [R] = kowMakeRegionBlock(regionparams, regioneqns, nregions)
R = zeros(regioneqns(nregions,2), nregions);
for r = 1:nregions
    
    R(regioneqns(r,1):regioneqns(r,2),r) = ones(regioneqns(r,2) - regioneqns(r,1) +1,1) ;
    
end
R = R.*regionparams;

end

