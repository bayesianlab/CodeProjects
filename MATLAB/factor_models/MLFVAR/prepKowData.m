clear;clc;
if ~exist('BigKow/', 'dir')
    mkdir('BigKow')
end
if ~exist('BigKow/RegionTests', 'dir')
    mkdir('BigKow/RegionTests')
end
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
% kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
% InfoCell{1,1} = [1,180];
% InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
% InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
% kow = table2array(kowdata)';
% dimX = (SeriesPerCountry+1)*SeriesPerCountry;
% colsX = 1:dimX;
% X = zeros(K*(T-1),SeriesPerCountry+1);
% fillX = 1:K;
% tempX = X(1:K, :);
% for t = 1:T-1
%     select2 = 1:SeriesPerCountry;
%     select3 = 1:dimX;
%     Xrows = fillX + (t-1)*K;
%     for c = 1:Countries
%         rows = select2 + (c-1)*SeriesPerCountry;
%         tempX(rows,:) =repmat([1, kow(rows, t)'],3,1);
%         cols = colsX + (c-1)*dimX;
%     end
%     X(Xrows,:) = tempX;
% end
% y = kow(:,1:end);
% 
% DataCell = cell(1,7);
% DataCell{1,1} = y(:,1:30);
% DataCell{1,2} = ones(K*(T-24),1);
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/aerreplication_raw.mat', 'DataCell')
% DataCell = cell(1,7);
% DataCell{1,1} = y;
% DataCell{1,2} = ones(K*(T),1);
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/constant_raw.mat', 'DataCell')
% DataCell = cell(1,7);
% DataCell{1,1} = y(:,2:end);
% DataCell{1,2} = X;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = 0;
% DataCell{1,5} = 0;
% DataCell{1,6} = 0;
% DataCell{1,7} = 0;
% save('BigKow/var1_raw.mat', 'DataCell')
%%%%%%%%%%%%%%%%%%%%
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
InfoCell{1,1} = [1,180];
InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=(kow- mean(kow,2))./std(kow,[],2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);

DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = ones(K*T,1);
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/constant_std.mat', 'DataCell')

DataCell = cell(1,7);
DataCell{1,1} = y(:, 1:30);
DataCell{1,2} = ones(K*(T-24),1);
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/aerreplication_std.mat', 'DataCell')

kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
InfoCell{1,1} = [1,180];
InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=(kow-mean(kow,2))./std(kow,[],2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/var1_std.mat', 'DataCell')


DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = ones(K*(T),1);
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/constant_std.mat', 'DataCell')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% World Region
clear;clc
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
InfoCell{1,1} = [1,180];
InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
% InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/world_region.mat', 'DataCell')

%%  World Country
clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
InfoCell{1,1} = [1,180];
% InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,2} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/world_country.mat', 'DataCell')

%%  World only
clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
InfoCell{1,1} = [1,180];
% InfoCell{1,2} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
% InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/world_only.mat', 'DataCell')

%%  Region only
clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
% InfoCell{1,1} = [1,180];
InfoCell{1,1} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
% InfoCell{1,3} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/region_only.mat', 'DataCell')

%%  Country only
clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
% InfoCell{1,1} = [1,180];
% InfoCell{1,1} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,1} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/country_only.mat', 'DataCell')


%%  Region Country
clear;clc;
SeriesPerCountry= 3;
Countries = 60;
K = 180;
T = 54;
kowdata = importRealData('~/GoogleDrive/Datasets/kow_march6.csv');
% InfoCell{1,1} = [1,180];
InfoCell{1,1} = [1,9; 10,15; 16,69; 70,123; 124,144;145,162;163,180];
InfoCell{1,2} = [(1:SeriesPerCountry:180)', (SeriesPerCountry:SeriesPerCountry:180)'];
kow = table2array(kowdata)';
kow=kow./std(kow,[],2);
kow = kow-mean(kow,2);
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerCountry+1);
fillX = 1:K;
tempX = X(1:K, :);
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
y = kow(:,1:54);
DataCell = cell(1,7);
DataCell{1,1} = y(:,2:end);
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('BigKow/RegionTests/region_country.mat', 'DataCell')
