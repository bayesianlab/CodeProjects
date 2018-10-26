function [  ] = kowdynfactorgibbs(KowData, restrictedStateVar, b0, B0inv,Sims )
Countries=60;
SeriesPerCountry=3;
lag= 3;
[T, ~] = size(KowData);
Eqns = Countries*SeriesPerCountry
storebeta = zeros(Eqns, Sims);
regionIndices = [1,4,6,24,42,49,55, 1000];
regioneqns = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
currobsmod = unifrnd(.5,1,Eqns,3);

obsEqnVariances = ones(Eqns,1);

RegionAr= unifrnd(.5,1, 7, lag) ;
CountryAr = unifrnd(.5,1, Countries, lag);
WorldAr = unifrnd(.5,1, 1,lag);

ar3init = zeros(3,1);


for i = 1 : Sims
    Sregion(:,:,:) = computeS123(RegionAr,...
        restrictedStateVar, T);
    Scountry(:,:,:) = computeS123(CountryAr,...
        restrictedStateVar, T);
    Sworld(:,:) = computeS123(WorldAr, restrictedStateVar, T);
    
    % Update mean function
    [beta, demeanedy] = kowupdateBetaPriors(KowData, currobsmod, obsEqnVariances, ...
        restrictedStateVar, Sworld,Sregion,Scountry, regionIndices, b0, B0inv);
%     storebeta(:,i) = beta;

    % Update Obs model
    
    [obsmodel] = kowmaximize(demeanedy, currobsmod, obsEqnVariances, Sworld, Sregion,...
        Scountry, regionIndices);
    
    % Update state 
    kowUpdateFactors(demeanedy, obsmodel', spdiags(obsEqnVariances,0, Eqns,Eqns),...
        WorldAr, RegionAr, CountryAr, regioneqns)  
    
    
end
end
