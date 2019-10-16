clear;clc;
worldunem= importWorldUE('~/GoogleDrive/Datasets/World Unemployment/world_unem.csv', 2, 29);
worldunem = table2array(worldunem)';


worldunem = log(worldunem(:,2:end)) - log(worldunem(:,1:end-1));
worldunem = worldunem - mean(worldunem,2);
worldunem = worldunem./std(worldunem,[],2);
[K,T] = size(worldunem);

SeriesPerCountry = 1;
Countries = 76;
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1,23; 24,47; 48,66; 67,76];
InfoCell{1,3} = [1,2;
    3,18;
    19,23;
    24,29;
    30,40;
    41,47;
    48,54;
    55,59;
    60,63;
    64,66;
    67,69;
    70,74;
    75,76];
I = kron(eye(K), ones(1,1+SeriesPerCountry));
select = 1:SeriesPerCountry;
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),  SeriesPerCountry*(SeriesPerCountry+1)*Countries);
fillX = 1:K;
tempX = X(1:K, :);

for t = 1:T-1
    select2 = 1:SeriesPerCountry;
    select3 = 1:dimX;
    Xrows = fillX + (t-1)*K;
    for c = 1:Countries
        rows = select2 + (c-1)*SeriesPerCountry;
        cols = colsX + (c-1)*dimX;
        tempX(rows,cols)= kron(eye(SeriesPerCountry), [1, worldunem(rows, t)']);
    end
    X(Xrows, :) = tempX;
end
X = sparse(X);
y = worldunem(:,2:T);
DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('Unemployment/worldue.mat', 'DataCell')