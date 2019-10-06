function [DataCell] = SimDataMLF(T, Regions, CountriesInRegion,SeriesPerCountry,beta)
rng(66)
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;
nFactors = 1 + Regions + Countries;
if nFactors == 3
    nFactors = 1;
end

rdex = 1:Regions;
InfoCell = cell(1,3);
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1:SeriesPerCountry*CountriesInRegion:K,;SeriesPerCountry*CountriesInRegion:SeriesPerCountry*CountriesInRegion:K]';
InfoCell{1,3} = [(1:SeriesPerCountry:K)',(SeriesPerCountry:SeriesPerCountry:K)'];
levels = size(InfoCell,2);

Xt = normrnd(0,1, K*T,(SeriesPerCountry+1));
Xt(:,1) = ones(K*T,1);
Xt = repmat(Xt,1,K);
E = repmat(kron(eye(K),ones(1,(SeriesPerCountry+1))),T,1);
Xt = E.*Xt;

% Parameter inits
beta = beta.*ones(K, (SeriesPerCountry+1));
beta= reshape(beta', (SeriesPerCountry+1)*K,1);



gamma = diag(unifrnd(0.1,.5,nFactors,1));
speyet = speye(T);
S = kowStatePrecision(gamma, ones(nFactors,1), T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);

FactorIndices = SetIndicesInFactor(InfoCell);

[Imat] = MakeObsIdentities(InfoCell,  K);

Xt = sparse(Xt);
Gh =unifrnd(.1,.9,K, levels);
for q = 1:levels
    if q == 1
        Gh(1,1) = 1;
    elseif q==2
        Gh(1:SeriesPerCountry*CountriesInRegion:K,2) = 1;
    else        
        Gh(1:SeriesPerCountry:K,3) = 1;
    end
end



Gt = MakeObsModel(Gh, Imat, FactorIndices);
size(Gt)
size(Factor)
muf = Gt*Factor;
mu = reshape(Xt*beta,K,T);

yt = mu +muf + normrnd(0,1,K,T);


DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = Factor;
DataCell{1,5} = beta;
DataCell{1,6} = gamma;
DataCell{1,7} = Gt;

end

