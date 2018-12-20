clear;clc;
% Dimension and setup
rng(1.6)

Regions = 2;
SeriesPerCountry = 3;
Countries = 4;
K = Countries*SeriesPerCountry;
nFactors = 1 + Regions + Countries;
RegionIndices = [1,6;7,12];
T = 100;
yt = zeros(K,T);
Factor = zeros(nFactors, T);
NXcols = Countries*SeriesPerCountry*(SeriesPerCountry+1);
Xt = zeros(K*T, NXcols);
mu = -ones(K,1);
% Parameter inits
beta = [.3,-.3,.3].*ones(SeriesPerCountry, SeriesPerCountry);
Beta = kron(eye(Countries),beta)

[I1, I2] = kowMakeObsModelIdentityMatrices(K, RegionIndices,SeriesPerCountry, Countries);
obsModel = [ones(K,1).*-.5, ones(K,1).*-.25,ones(K,1).*(.25)];

Gt = [ones(K,1).*.1, I1.*ones(K,1).*0, I2.*(ones(K,1).*0) ];
gamma = .40.*ones(nFactors,1);
% Init factor
variance = 1/(1-(.40.^2));
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
tempsto = zeros(K, NXcols);

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



kowDynFac(yt, Xt, RegionIndices, Countries, SeriesPerCountry, 1)


