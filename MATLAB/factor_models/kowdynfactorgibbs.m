function [ h ] = kowdynfactorgibbs(ys, SurX, KowData, restrictedStateVar, b0, B0inv,Sims )
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 5, 'Display', 'off');
%% TODO 
% Create and update all functions that use obsEqnVariances to 
% handle the precision. Aviods unecessary calculations
% Possibly the Sregion and Scountry matrices could be saved 
% from the update obs model step instead of recreated twice in the updating
% of the  latent states. 
Countries=60;
Regions = 7;
SeriesPerCountry=3;
nFactors = Countries + Regions + 1;
Arp= 3;
[T, ~] = size(KowData);
Eqns = Countries*SeriesPerCountry
blocks = 30;
storebeta = zeros(Eqns, Sims);
regionIndices = [1,4,6,24,42,49,55, -1];
regioneqns = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
countryeqns = [(1:3:178)', (3:3:180)'];
[IOregion,IOcountry] = kowMakeObsModelIdentityMatrices(Eqns, regioneqns, SeriesPerCountry, Regions,Countries);
zeroOutRegion = zeros(size(IOregion));
zeroOutCountry = zeros(size(IOcountry));
zeroOutWorld = zeros(Eqns, 1);
% Should be passed in as parameters

CountryObsModelPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryObsModelPriorlogdet = SeriesPerCountry*log(1e-2);
eqnspblock = Eqns/blocks;
WorldObsModelPriorPrecision = 1e-2.*eye(eqnspblock);
WorldObsModelPriorlogdet = eqnspblock*log(1e-2);
currobsmod = unifrnd(0, 1,Eqns, 3);

countriesInFt = 9:68;
regionsInFt = 2:8;
[kowMakeRegionBlock(currobsmod(:,2), regioneqns, 7), kowMakeRegionBlock(currobsmod(:,3), countryeqns, 60)];

obsEqnVariances = ones(Eqns,1);
obsEqnPrecision = 1./obsEqnVariances;
RegionAr= unifrnd(.1,.2,Regions,Arp) ;
CountryAr = unifrnd(-.1,.2, Countries,Arp);
WorldAr = unifrnd(-.1,.2, 1,Arp);

stacktrans = [WorldAr;RegionAr;CountryAr];



T= 20
smally = ys(:,1:T);
smallx = SurX(1:Eqns*T, :);




StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];

Si = kowMakeVariance(stacktrans,1, T);

mux = zeros(Eqns*T,1);
ydemu = smally(:)- mux;

ydemut = reshape(ydemu,Eqns,T);


vecF = kowUpdateLatent(ydemu, StateObsModel, Si, obsEqnVariances, T); 
Ft = reshape(vecF, 68,20);



% 
% 
% 











for i = 1 : Sims
    
    % Update mean function
    [beta, ydemut] = kowupdateBetaPriors(smally(:), smallx, obsEqnPrecision,...
        StateObsModel, Si,  T);

    % Update Obs model
    tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), zeroOutCountry .* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft;
    currobsmod(:,3) = kowUpdateCountryObsModel(tempydemut, obsEqnVariances,currobsmod(:,3),...
        CountryAr,Countries, SeriesPerCountry, options,...
        CountryObsModelPriorPrecision, CountryObsModelPriorlogdet, T);
    CFt = kowUpdateCountryFactor(tempydemut,obsEqnVariances, currobsmod(:,3),...
             CountryAr, Countries, SeriesPerCountry, T)
%     
%     Ft(countriesInFt, :) = CFt
%     tempStateObsModel = [currobsmod(:,1), zeroOutRegion .* currobsmod(:,2), IOcountry.* currobsmod(:,3)];
%     tempydemut = ydemut - tempStateObsModel*Ft;         
%     currobsmod(:,2) = kowUpdateRegionObsModel(tempydemut, obsEqnVariances,currobsmod(:,2),...
%         CountryAr,Countries, SeriesPerCountry, options,...
%         CountryObsModelPriorPrecision, CountryObsModelPriorlogdet, regionIndices, T);    
%     kowUpdateRegionFactor(tempydemut, obsEqnPrecision, currobsmod(:,2),RegionAr, regioneqns, T)
%     
%     tempStateObsModel = [zeroOutWorld, zeroOutRegion .* currobsmod(:,2), IOcountry.* currobsmod(:,3)];
%     tempydemut = ydemut - tempStateObsModel*Ft;  
%     [worldob, Sworld] = kowUpdateWorldObsModel(tempydemut, obsEqnVariances,currobsmod(:,1),...
%                 WorldAr, options, WorldObsModelPriorPrecision,...
%                 WorldObsModelPriorlogdet, blocks,Eqns, T);
%     currobsmod(:,1) = worldob;
%     kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld, obsEqnVariances, T)'
         
    
    % Update state 
%     kowUpdateFactors(demeanedy, obsmodel', spdiags(obsEqnVariances,0, Eqns,Eqns),...
%         WorldAr, RegionAr, CountryAr, regioneqns)  
    
    
end
end
