clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
kow = table2array(kowdata)';
InfoCell{1,1} = [1,180];
InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];

kowmus = mean(kow,2);
kow = kow./std(kow,[],2);
kow=kow - kowmus;

select = 1:SeriesPerCountry;
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);

I = kron(eye(K), ones(1,1+SeriesPerCountry));
fillX = 1:K;
tempX = X(1:K, :);

d=0;
for t = 1:T-1
    select2 = 1:SeriesPerCountry;
    select3 = 1:dimX;
    Xrows = fillX + (t-1)*K;
    for c = 1:Countries
        rows = select2 + (c-1)*SeriesPerCountry;
        tempX(rows,:) =repmat([1, kow(rows, t)'],3,1);
        cols = colsX + (c-1)*dimX;
    end
    X(Xrows,:) = tempX;
end

y = kow(:,2:54);


% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = X;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kow.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = ones(K*(T-1),1);
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kose.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = ones(K*(T-1),1);
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kose_replication.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = X;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kow_standardized.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = X;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kow_notcentered.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = X;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kowz_notcentered_kose.mat', 'DataCell')

% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = ones(K*(T-1),1);
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/kowz_notcentered_resurrection.mat', 'DataCell')

