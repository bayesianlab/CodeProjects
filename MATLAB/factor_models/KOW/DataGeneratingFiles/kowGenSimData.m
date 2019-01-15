function [yt, Xt, Factor, RegionIndices, CountriesThatStartRegions ] =...
    kowGenSimData(T, Regions, CountriesInRegion,SeriesPerCountry, mu, beta, G, gamma)
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;
nFactors = 1 + Regions + Countries;
rdex = 1:SeriesPerCountry*CountriesInRegion;
RegionIndices = zeros(Regions, 2);
for r = 1:Regions
    q = rdex + (r-1)*CountriesInRegion*SeriesPerCountry;
    RegionIndices(r,:) = [q(1), q(end)];
end
yt = zeros(K,T);
Factor = zeros(nFactors, T);
NXcols = Countries*SeriesPerCountry*(SeriesPerCountry+1);
Xt = zeros(K*T, NXcols);

% Parameter inits
beta = beta.*ones(SeriesPerCountry, SeriesPerCountry);
Beta = kron(eye(Countries),beta);

[I1, I2] = kowMakeObsModelIdentityMatrices(K, RegionIndices,SeriesPerCountry,...
    Countries);
obsModel = [ones(K,1).*G(1), ones(K,1).*G(2),ones(K,1).*G(3)];
obsModel(1,1) = .5;
for r = 1:Regions
   obsModel(RegionIndices(r,1), 2) = ...
       abs(obsModel(RegionIndices(r,1), 2));  
end
obsModel(1:SeriesPerCountry:end,3) = abs(obsModel(1:SeriesPerCountry:end,3));
Gt = [ones(K,1).*obsModel(:,1), I1.*obsModel(:,2), I2.*obsModel(:,3) ];
gamma = gamma.*ones(nFactors,1);
% Init factor
variance = 1/(1-(gamma(1)^2));
Factor(:,1) = normrnd(0,variance, nFactors,1);
% Init first obs

yt(:,1) = normrnd(0,1,K,1);
for t= 2:T
   yt(:,t) = mu + Beta*yt(:,t-1)  + Gt*Factor(:,t-1) + normrnd(0,1,K,1);
   Factor(:,t) = gamma.*Factor(:,t-1) + normrnd(0, 1,nFactors,1);
end
% Create Xt matrix for vectorized yt
s = 1:SeriesPerCountry;
s1 = 1:SeriesPerCountry*(SeriesPerCountry+1);
take = 1:K;

for t= 1:T
    tx = take + (t-1)*K;
    for c = 1:Countries
        rowsx = s + (c-1)*SeriesPerCountry;
        rowsx = tx(rowsx);
        getCountry = s + (c-1)*SeriesPerCountry;
        fillx = s1 + (c-1)*SeriesPerCountry*(SeriesPerCountry+1);
        Xt(rowsx, fillx) = kron(eye(SeriesPerCountry), [1,yt(getCountry,t)']);
    end
end
% Take out an obs for VAR(1) 

Xt = Xt(1:(T-1)*K,:);
Xt = sparse(Xt);
yt = yt(:, 2:T);
CountriesThatStartRegions = [1:SeriesPerCountry:(CountriesInRegion*Regions), -1];
end

