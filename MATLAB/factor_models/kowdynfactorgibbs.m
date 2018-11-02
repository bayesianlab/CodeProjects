function [ h ] = kowdynfactorgibbs(ys, SurX, KowData, restrictedStateVar, b0, B0inv,Sims )
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


currobsmod = unifrnd(.5,1,Eqns,3);
[kowMakeRegionBlock(currobsmod(:,2), regioneqns, 7), kowMakeRegionBlock(currobsmod(:,3), countryeqns, 60)];
obsEqnVariances = ones(Eqns,1);

RegionAr= unifrnd(.1,.2,Regions,Arp) ;
CountryAr = unifrnd(-.1,.2, Countries,Arp);
WorldAr = unifrnd(-.1,.2, 1,Arp);

stacktrans = [WorldAr;RegionAr;CountryAr];

% [P0, Phi] = kowComputeP0(stacktrans);

% Phi = [Phi, eye(nFactors), zeros(nFactors, nFactors*2)];
% size(Phi)
p1 = stacktrans(1:3,:);

% p = stacktrans(1:2,:);
% p=full(spdiags(p, [0, 2:2:4], 2, 6));
% I = [eye(2), zeros(2,4)];
% kron([[0;0],eye(2)], I) + kron([eye(2), [0;0]], p);
% kron([eye(2), [0;0]], p)
T = 51;
testys = ys;
testp =  stacktrans(1:3,:);
P0 = kowComputeP0(stacktrans);



Si = kowMakeVariance(stacktrans,  1, T);

StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];
uu = (Si + kron(speye(T), StateObsModel'*StateObsModel))\speye(size(Si,1));

% kowUpdateLatent(testys(:), StateObsModel, Si, 1, T)

kowupdateBetaPriors(ys(:), SurX, diag(1./obsEqnVariances), StateObsModel, Si, Eqns, nFactors, T)
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
