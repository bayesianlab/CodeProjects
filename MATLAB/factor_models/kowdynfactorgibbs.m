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
storebeta = zeros(Eqns, Sims);
regionIndices = [1,4,6,24,42,49,55, -1];
regioneqns = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
countryeqns = [(1:3:178)', (3:3:180)'];
[IOregion,IOcountry] = kowMakeObsModelIdentityMatrices(Eqns, regioneqns, SeriesPerCountry, Regions,Countries);
% Should be passed in as parameters

CountryObsModelPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryObsModelPriorlogdet = SeriesPerCountry*log(1e-2);
% currobsmod = unifrnd(.5,1,Eqns,3);
currobsmod = unifrnd(0, 1,Eqns, 3);
[kowMakeRegionBlock(currobsmod(:,2), regioneqns, 7), kowMakeRegionBlock(currobsmod(:,3), countryeqns, 60)];
obsEqnVariances = ones(Eqns,1);

RegionAr= unifrnd(.1,.2,Regions,Arp) ;
CountryAr = unifrnd(-.1,.2, Countries,Arp);
WorldAr = unifrnd(-.1,.2, 1,Arp);

stacktrans = [WorldAr;RegionAr;CountryAr];

% [P0, Phi] = kowComputeP0(stacktrans);
% 
% Phi = [Phi, eye(nFactors), zeros(nFactors, nFactors*2)];
% size(Phi) 
% p = stacktrans(1:1,:);
% 
% [si,p, s] = kowMakeVariance(p, 1, 5);

T= 20
smally = ys(:,1:T);
smallx = SurX(1:Eqns*T, :);


% 
% StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];
% StateVariable = reshape(kowUpdateLatent(smally(:), StateObsModel, Si, 1, T), nFactors, T);
% ss = StateObsModel*StateVariable;

% beta = kowupdateBetaPriors(smally(:), smallx, diag(1./obsEqnVariances), StateObsModel, Si, Eqns, nFactors, T);
% mux = smallx*beta;
mux = zeros(Eqns*T,1);
ydemu = smally(:)- mux;

ydemut = reshape(ydemu,Eqns,T);
[Scountryprecision] = kowMakeVariance(CountryAr(1,:), 1, T);






% kowUpdateCountryObsModel(ydemut, obsEqnVariances,currobsmod(:,3),...
%     CountryAr,Countries, SeriesPerCountry, options,...
%     CountryObsModelPriorPrecision, CountryObsModelPriorlogdet, T)

kowUpdateCountryFactor(ydemut,obsEqnVariances, currobsmod(:,3),...
    CountryAr, Countries, SeriesPerCountry, T);


t = 1:SeriesPerCountry;

regioncount = 1;
regioncheck = 0;
for c = 1:Countries
    if c == regionIndices(regioncount) 
        regioncount = regioncount + 1;
        regioncheck = regioncheck + 1;
    end
    selectC = t + (c-1)*SeriesPerCountry;
    obsslice = currobsmod(selectC,2);
    yslice = ydemut(selectC, :);
    pslice = 1./obsEqnVariances(selectC, :);
    [Sregionpre] = kowMakeVariance(RegionAr(regioncheck,:), 1, T);
    loglike = @(rg) -kowLL(rg, yslice(:),...
        Sregionpre, pslice, SeriesPerCountry,T); 
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice, options);    
 
end

for i = 1 : Sims
    
    % Update mean function
%     [beta, demeanedy] = kowupdateBetaPriors(KowData, currobsmod, obsEqnVariances, ...
%         restrictedStateVar, Sworld,Sregion,Scountry, regionIndices, b0, B0inv);
%     storebeta(:,i) = beta;

    % Update Obs model
%     
%     [obsmodel] = kowmaximize(demeanedy, currobsmod, obsEqnVariances, Sworld, Sregion,...
%         Scountry, regionIndices);
    
    % Update state 
%     kowUpdateFactors(demeanedy, obsmodel', spdiags(obsEqnVariances,0, Eqns,Eqns),...
%         WorldAr, RegionAr, CountryAr, regioneqns)  
    
    
end
end
