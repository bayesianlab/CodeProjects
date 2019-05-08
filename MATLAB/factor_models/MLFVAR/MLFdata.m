function [DataCell] = MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, identification)
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;
InfoMat = zeros(K,1);
nFactors = 1 + Regions + Countries;
rdex = 1:Regions;
InfoCell = cell(1,3);
% InfoCell{1,1} = kron(rdex', ones(CountriesInRegion,1));
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1:SeriesPerCountry*CountriesInRegion:K;SeriesPerCountry*CountriesInRegion:SeriesPerCountry*CountriesInRegion:K]';
InfoCell{1,3} = [(1:SeriesPerCountry:K)', (SeriesPerCountry:SeriesPerCountry:K)'];

% Xt = normrnd(0,1, K*T,(SeriesPerCountry+1));
% Xt(:,1) = ones(K*T,1);
% Xt = repmat(Xt,1,K);
% E = repmat(kron(eye(K),ones(1,(SeriesPerCountry+1))),T,1);
% Xt = E.*Xt;

% Parameter inits
beta = beta.*ones(K, (SeriesPerCountry+1));
beta= reshape(beta', (SeriesPerCountry+1)*K,1);

gam = unifrnd(.5,.6,nFactors,1);
stateTransitionsAll = gam'.*eye(nFactors);
speyet = speye(T);

S = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);


[Identities, sectorInfo] = MakeObsModelIdentity(InfoCell);

I1 = Identities{1,2};
I2 = Identities{1,3};
Z0 = zeros(K,1);
Z1 = zeros(size(I1,1), size(I1,2));
Z2 = zeros(size(I2,1), size(I2,2));
% Gt = .3.*ones(K,3);
Gt = unifrnd(.5,.99,K,3);
WorldOnly = Gt(:,1);
RegionsOnly = Gt(:,2).*I1;
CountriesOnly = Gt(:,3).*I2;
% Gt = [WorldOnly, RegionsOnly,CountriesOnly];
Gt = [WorldOnly, RegionsOnly, Z2];
if identification == 2
    WorldOnly(1,1) = 1;
    Start1 = InfoCell{1,2};
    Start1 = Start1(:,1);
    for j = 1:length(Start1)
        RegionsOnly(Start1(j), j) = 1;
    end
    Start1 = InfoCell{1,3};
    Start1 = Start1(:,1);
    for q = 1:length(Start1)
        CountriesOnly(Start1(q),q) = 1;
    end
    Gt = [WorldOnly, RegionsOnly, CountriesOnly];
end
Gt

mu = Gt*Factor;
yt = mu + normrnd(0,1,K,T);
% Xt = sparse(Xt);

Gt = [Gt(:,1), sum(Gt(:,2:Regions+1),2), sum(Gt(:,Regions+2:end),2)];
Xt =0;
DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = Factor;
DataCell{1,5} = beta;
DataCell{1,6} = gam;
DataCell{1,7} = Gt;


end

