function [DataCell] = MLDFVARdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gam)
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;

nFactors = 1 + Regions + Countries;
rdex = 1:Regions;
cdex = 1:Countries;
InfoCell = cell(1,3);
% InfoCell{1,1} = kron(rdex', ones(CountriesInRegion,1));
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1:SeriesPerCountry*CountriesInRegion:K;SeriesPerCountry*CountriesInRegion:SeriesPerCountry*CountriesInRegion:K]';
InfoCell{1,3} = [(1:SeriesPerCountry:K)', (SeriesPerCountry:SeriesPerCountry:K)'];

% TODO Do all this internally in MLDFVAR
regVec = zeros(SeriesPerCountry*CountriesInRegion,1);
regVec(1) = 1;
R = sum(kron(eye(Regions), regVec),2);
counVec = zeros(SeriesPerCountry,1);
counVec(1)=1;
C = sum(kron(eye(Countries),counVec),2);
W = [1; zeros(K-1,1)];
RestrictionInfo = [W,R,C];

InfoCell2{1,1} = RestrictionInfo;

% Parameter inits
beta = beta.*ones(K, (SeriesPerCountry+1));
beta= reshape(beta', (SeriesPerCountry+1)*K,1);

stateTransitionsAll = gam'.*eye(nFactors);
speyet = speye(T);
S = kowStatePrecision(stateTransitionsAll, 1, T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);


[Identities, sectorInfo] = MakeObsModelIdentity(InfoCell);
I1 = Identities{1,2};
I2 = Identities{1,3};

Z0 = zeros(K,1);
Z1 = zeros(size(I1,1), size(I1,2));
Z2 = zeros(size(I2,1), size(I2,2));
Gt = unifrnd(.6,.7,K,nFactors).*[ones(K,1), I1, I2]; 

Gt(1,1) = 1;
RegionInfo = InfoCell{1,2};
for r =1:Regions
    Gt(RegionInfo(r,1), 1+r) = 1;
end
CountryInfo = InfoCell{1,3};
for c =1:Countries
    Gt(CountryInfo(c,1), 1+ Regions+c) = 1;
end

WorldOnly = Gt(:,1);
RegionsOnly = Gt(:,2:Regions+1);
CountriesOnly = Gt(:,1+Regions+1:Countries+1+Regions);
Gt = [WorldOnly, RegionsOnly,CountriesOnly];


mu = Gt*Factor;
yt = mu + normrnd(0,1,K,T);
% Xt = sparse(Xt);

Gt = [Gt(:,1), sum(Gt(:,2:Regions+1),2), sum(Gt(:,Regions+2:end),2)];
Xt =0;

regionVec = kron(eye(Regions), ones(CountriesInRegion,1) ).*(rdex+1)

InfoCell2{1,2} = [ones(Countries,1), sum(regionVec,2), sum(diag(cdex+Regions+1),2)];

DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = InfoCell2;
DataCell{1,5} = Factor;
DataCell{1,6} = beta;
DataCell{1,7} = gam;
DataCell{1,8} = Gt;


end
