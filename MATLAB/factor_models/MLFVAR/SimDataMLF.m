function [DataCell] = SimDataMLF(T, Regions, CountriesInRegion,SeriesPerCountry)
rng(60)
stateLags=2;
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;
if Regions == 1 & CountriesInRegion == 1
    nFactors =1 ;
    InfoCell{1,1} = [1,K]
elseif Regions == 1 & CountriesInRegion > 1
    nFactors = 1 + CountriesInRegion;
    InfoCell = cell(1,2);
    InfoCell{1,1} = [1,K];
    InfoCell{1,2} = [(1:SeriesPerCountry:K)',(SeriesPerCountry:SeriesPerCountry:K)'];
else
    nFactors = 1 + Regions + Countries;
    InfoCell = cell(1,3);
    InfoCell{1,1} = [1,K];
    InfoCell{1,2} = [1:SeriesPerCountry*CountriesInRegion:K,;SeriesPerCountry*CountriesInRegion:SeriesPerCountry*CountriesInRegion:K]';
    InfoCell{1,3} = [(1:SeriesPerCountry:K)',(SeriesPerCountry:SeriesPerCountry:K)'];
end

Xt = [ones(K*T,1)];
surX = surForm(Xt,K);

% Parameter inits
beta = ones(size(surX,2),1);
gamma = zeros(nFactors,stateLags);
Factor = zeros(nFactors,T);
for q = 1:nFactors
    gamma(q,:) = initializeARparams(1,stateLags);
    ip = initCovar(gamma(q,:));
    [Lambda,~]=FactorPrecision(gamma(q,:),ip, 1, T);
    Linv = chol(Lambda, 'lower')\eye(T);
    Factor(q,:) = reshape(Linv'*normrnd(0,1,T,1),1,T);
end
FactorIndices = SetIndicesInFactor(InfoCell);

[Imat] = MakeObsIdentities(InfoCell,  K);

Gh =setGt(InfoCell);
Gt = MakeObsModel(Gh, Imat, FactorIndices);
muf = Gt*Factor;
mu = reshape(surX*beta,K,T);

yt = mu +muf + normrnd(0,1,K,T);


DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = Factor;
DataCell{1,5} = beta;
DataCell{1,6} = gamma;
DataCell{1,7} = ConvertStateObsModel( Gt, FactorIndices);

end

