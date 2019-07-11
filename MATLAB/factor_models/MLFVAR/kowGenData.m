function [yt, SurX] = kowGenData()

% kowImport
% kowdata = kowImportFunction('~/Datasets/kow.csv', 2, 55)

kowdata=kowImportFunction('~/GoogleDrive/Datasets/kowdetaildata.csv', 2, 55);
alldata = table2array(kowdata(:,2:end))';
InfoCell = cell(1,3);
% 3 North America
% 2 Oceania
% 18 LA
% 18 Europe
% 7 Africa
% 6 Asia (D)
% 6 Asia (Dev)
InfoCell{1,1} = [ones(3,1); 2.*ones(2,1); 3.*ones(18,1); 4.*ones(18,1); 5.*ones(7,1);6.*ones(6,1); 7.*ones(6,1)];
InfoCell{1,2} = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
SeriesPerCountry= 3;
InfoCell{1,3} = SeriesPerCountry;

lags = 3;
kd = kowPrepKowData(alldata',lags);
b0 = zeros(lags+1,1); 
B0 = 100.* eye(length(b0));
restrictedvar = 1;

dexsy = 1:5:size(kd,2);
dexsx = setdiff(1:size(kd,2), dexsy);
yt = kd(:,dexsy)';

[K, T] = size(yt);
Xs = kd(:, dexsx);
spcolX = speye(K);
formsurI = kron(spcolX, ones(1,4));

SurX = zeros(K*T, size(Xs,2));
t = 1:K;

for r = 1:size(Xs,1)
    select = t + (r-1)*K;
    SurX(select, :) = formsurI.*Xs(r,:);
end
kowy = yt;
kowx = SurX;
Xt = SurX;
Factor = 0;
beta = 0;
gamma = 0;
G = 0;




save('kow.mat', 'kowy', 'kowx');
DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = Factor;
DataCell{1,4} = InfoCell;
DataCell{1,5} = beta;
DataCell{1,6} = gamma;
DataCell{1,7} = G;

save('WorldData.mat', 'DataCell')
end

