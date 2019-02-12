function [DataCell] = MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma)
Countries = Regions*CountriesInRegion;
K = Countries*SeriesPerCountry;
InfoMat = zeros(K,1);
nFactors = 1 + Regions + Countries;
rdex = 1:Regions;
InfoCell = cell(1,3);
InfoCell{1,1} = kron(rdex', ones(CountriesInRegion,1));
InfoCell{1,2} = [1:SeriesPerCountry*CountriesInRegion:K;SeriesPerCountry*CountriesInRegion:SeriesPerCountry*CountriesInRegion:K]';
InfoCell{1,3} = SeriesPerCountry;

InfoMat = InfoCell{1,1};
Xt = normrnd(0,1, K*T,(SeriesPerCountry+1));
Xt(:,1) = ones(K*T,1);
Xt = repmat(Xt,1,K);
E = repmat(kron(eye(K),ones(1,(SeriesPerCountry+1))),T,1);
Xt = E.*Xt;

% Parameter inits
beta = beta.*ones(K, (SeriesPerCountry+1));
beta= reshape(beta', (SeriesPerCountry+1)*K,1);


stateTransitionsAll = gamma'.*eye(nFactors);

W = kowStatePrecision(gamma(1), 1, T);


% Fw = mvnrnd(zeros(1,T), W);
% Fr = zeros(Regions, T);
% for r = 1:Regions
%     R = kowStatePrecision(gamma(1+r), 1, T);
%     Fr(r,:) = mvnrnd(zeros(1,T), R);
% end
% Fc = zeros(Countries,T);
% for c = 1:Countries
%     C = kowStatePrecision(gamma(3) , 1, T); 
%     Fc(c,:) =mvnrnd(zeros(1,T), C);
% end
% 
% Factor = [Fw;Fr;Fc];

S = kowStatePrecision( stateTransitionsAll, 1, T) \ speye(nFactors*T);

Factor = reshape(mvnrnd(zeros(1,nFactors*T), S)', nFactors, T);

[I1, I2] = MakeObsModelIdentity(InfoMat, SeriesPerCountry);

Gt = [ones(K,1).*G(1), I1.*G(2), I2.*G(3)];

% mu = reshape(Xt*beta, K,T) + Gt*Factor;
mu = Gt*Factor;
yt = mu + normrnd(0,1,K,T);
Xt = sparse(Xt);

DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = Factor;
DataCell{1,4} = InfoCell;
DataCell{1,5} = beta;
DataCell{1,6} = gamma;
DataCell{1,7} = G;


end

