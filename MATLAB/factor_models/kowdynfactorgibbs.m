function [  ] = kowdynfactorgibbs(KowData, restrictedStateVar, b0, B0inv,Sims )
Countries=60;
SeriesPerCountry=3;
lag= 3;
[T, ~] = size(KowData);
storebeta = zeros(Countries*SeriesPerCountry, Sims);
regionIndices = [1,4,6,24,42,49,55, 1000];
currobsmod = unifrnd(.5,1,Countries*SeriesPerCountry,3);

obsEqnVars = unifrnd(.1,1, 60,1);

RegionAr= unifrnd(.5,1, 7, lag) ;
CountryAr = unifrnd(.5,1, Countries, lag);
WorldAr = unifrnd(.5,1, 1,lag);

for i = 1 : Sims
    Sregion(:,:,:) = computeS123(RegionAr,...
        restrictedStateVar, T);
    Scountry(:,:,:) = computeS123(CountryAr,...
        restrictedStateVar, T);
    Sworld(:,:) = computeS123(WorldAr, restrictedStateVar, T);
    
    % Update mean function
    [beta, demeanedy] = kowupdateBetaPriors(KowData, currobsmod, obsEqnVars, ...
        restrictedStateVar, Sworld,Sregion,Scountry, regionIndices, b0, B0inv);
%     storebeta(:,i) = beta;

    % Update Obs model
%     kowll(demeanedy(:,1), 1, currobsmod(1,1), currobsmod(1,2), currobsmod(1,3),...
%         Sworld, Sregion(:,:,1), Scountry(:,:,1), .05)
    kowmaximize(demeanedy, currobsmod, obsEqnVars, Sworld, Sregion, Scountry, regionIndices)
    
    
end
end
