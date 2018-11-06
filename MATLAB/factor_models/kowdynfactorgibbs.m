function [ h ] = kowdynfactorgibbs(ys, SurX, KowData, restrictedStateVar, b0, B0inv,Sims )
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 3, 'Display', 'off');

Countries=60;
Regions = 7;
SeriesPerCountry=3;
nFactors = Countries + Regions + 1;
Arp= 3;
[T, ~] = size(KowData);
Eqns = Countries*SeriesPerCountry
storebeta = zeros(Eqns, Sims);
% regionIndices = [1,4,6,24,42,49,55, 1000];
regioneqns = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
countryeqns = [(1:3:178)', (3:3:180)'];
[IOregion,IOcountry] = kowMakeObsModelIdentityMatrices(Eqns, regioneqns, SeriesPerCountry, Regions,Countries);
% Should be passed in as parameters


% currobsmod = unifrnd(.5,1,Eqns,3);
currobsmod = zeros(Eqns,3);
[kowMakeRegionBlock(currobsmod(:,2), regioneqns, 7), kowMakeRegionBlock(currobsmod(:,3), countryeqns, 60)];
obsEqnVariances = ones(Eqns,1);

RegionAr= unifrnd(.1,.2,Regions,Arp) ;
CountryAr = unifrnd(-.1,.2, Countries,Arp);
WorldAr = unifrnd(-.1,.2, 1,Arp);

stacktrans = [WorldAr;RegionAr;CountryAr];

% [P0, Phi] = kowComputeP0(stacktrans);

% Phi = [Phi, eye(nFactors), zeros(nFactors, nFactors*2)];
% size(Phi) 
% p = stacktrans(1:2,:);
% 
% [si,p, s] = kowMakeVariance(p, 1, 5);
% p
smally = ys(:,1:T);
smallx = SurX(1:Eqns*T, :);
[Si, p, S ] = kowMakeVariance(stacktrans,  1, T);

StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];
StateVariable = reshape(kowUpdateLatent(smally(:), StateObsModel, Si, 1, T), nFactors, T);
ss = StateObsModel*StateVariable;
size(ss(:))

beta = kowupdateBetaPriors(smally(:), smallx, diag(1./obsEqnVariances), StateObsModel, Si, Eqns, nFactors, T);
mux = smallx*beta;
ydemu = smally(:)- mux;
shapeddemeany = reshape(ydemu,Eqns,T);
loglike = @(wg) -kowOptimizeWorld(wg, currobsmod, IOregion, IOcountry, StateVariable, ydemu, repmat(obsEqnVariances, T,1));
[themean, ~,~,~,~, Hessian] = fminunc(loglike, currobsmod(:,1), options);

mhWorld(ydemu, obsEqnVariances,currobsmod, themean, Hessian, StateVariable, IOregion, IOcountry, Eqns, T)

for r = 1:Regions
    bdex = regioneqns(r,1);
    edex = regioneqns(r,2);
    reqns = edex - bdex + 1;
    obsslice = currobsmod(bdex:edex,:);
    yslice = shapeddemeany(bdex:edex, :);
    vslice = obsEqnVariances(bdex:edex, :);
    regguess = currobsmod(bdex:edex,2)
    regionidentityslice = IOregion(bdex:edex,:);
    countryidentityslice = IOcountry(bdex:edex,:);
    loglike = @(rg) -kowOptimizeRegion(rg, currobsmod, IOregion, IOcountry, StateVariable,...
        ydemu, spdiags(repmat(obsEqnVariances, T,1), 0, T*Eqns, T*Eqns), bdex, edex, T);
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, regguess, options);
%     mhRegion(yslice(:),vslice,obsslice, themean, Hessian, StateVariable, S, regionidentityslice, countryidentityslice, reqns, T)

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
