function [ h ] = kowdynfactorgibbs(ys, SurX, KowData, restrictedStateVar, b0, B0inv,Sims )
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 5, 'Display', 'off');
%% TODO 
% Create and update all functions that use obsEqnVariances to 
% handle the precision. Aviods unecessary calculations

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
% Should be passed in as parameters

CountryObsModelPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryObsModelPriorlogdet = SeriesPerCountry*log(1e-2);
eqnspblock = Eqns/blocks;
WorldObsModelPriorPrecision = 1e-2.*eye(eqnspblock);
WorldObsModelPriorlogdet = eqnspblock*log(1e-2);
% currobsmod = unifrnd(.5,1,Eqns,3);
currobsmod = unifrnd(0, 1,Eqns, 3);
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

% mux = smallx*beta;
mux = zeros(Eqns*T,1);
ydemu = smally(:)- mux;

ydemut = reshape(ydemu,Eqns,T);
[Scountryprecision] = kowMakeVariance(CountryAr(1,:), 1, T);



[worldob, Sworld] = kowUpdateWorldObsModel(ydemut, obsEqnVariances,currobsmod(:,1),...
    WorldAr, options, WorldObsModelPriorPrecision,...
    WorldObsModelPriorlogdet, blocks,Eqns, T);


w = kowUpdateLatent(ydemut(:),currobsmod(:,1), Sworld, obsEqnVariances, T)'

r = kowUpdateRegionFactor(ydemut, obsEqnPrecision, currobsmod(:,2),RegionAr, regioneqns, T)

c = kowUpdateCountryFactor(ydemut,obsEqnVariances, currobsmod(:,3),...
    CountryAr, Countries, SeriesPerCountry, T)

size([w;r;c])

% kowUpdateRegionObsModel(ydemut, obsEqnVariances,currobsmod(:,2),...
%     CountryAr,Countries, SeriesPerCountry, options,...
%     CountryObsModelPriorPrecision, CountryObsModelPriorlogdet, regionIndices, T)







for i = 1 : Sims
    
    % Update mean function
    [beta, ydemu] = kowupdateBetaPriors(smally(:), smallx, 1./obsEqnVariances,...
        StateObsModel, Si, Eqns, nFactors, T);
%     storebeta(:,i) = beta;

    % Update Obs model
    
%     kowUpdateCountryObsModel(ydemut, obsEqnVariances,currobsmod(:,3),...
%         CountryAr,Countries, SeriesPerCountry, options,...
%         CountryObsModelPriorPrecision, CountryObsModelPriorlogdet, T)
    
    
    % Update state 
%     kowUpdateFactors(demeanedy, obsmodel', spdiags(obsEqnVariances,0, Eqns,Eqns),...
%         WorldAr, RegionAr, CountryAr, regioneqns)  
    
    
end
end
