clear;clc;
money = importmoney('~/GoogleDrive/Datasets/Inflation and Growth/mpy.csv', 2,52 );
mpy = money(:, 2:88);
mpy = table2array(mpy)';

smpy = std(mpy,[],2);
mpy = (mpy - mean(mpy,2))./smpy;

[K,T] = size(mpy);
SeriesPerCountry = 3;
Countries = 29;
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1,54 ; 55,K];
InfoCell{1,3} = [(1:SeriesPerCountry:K)', (SeriesPerCountry:SeriesPerCountry:K)'];

SeriesPerCountry = 3;
Countries = 29;

select = 1:SeriesPerCountry;
dimX = (SeriesPerCountry+1)*SeriesPerCountry;
colsX = 1:dimX;
X = zeros(K*(T-1),  SeriesPerCountry*(SeriesPerCountry+1)*Countries);

I = kron(eye(K), ones(1,1+SeriesPerCountry));
fillX = 1:K;
tempX = X(1:K, :);

for t = 1:T-1
    select2 = 1:SeriesPerCountry;
    select3 = 1:dimX;
    Xrows = fillX + (t-1)*K;
    for c = 1:Countries
        rows = select2 + (c-1)*SeriesPerCountry;
        cols = colsX + (c-1)*dimX;
        tempX(rows,cols)= kron(eye(SeriesPerCountry), [1, mpy(rows, t)']);
    end
    X(Xrows, :) = tempX;
end
X = sparse(X);
y = mpy(:,2:51);

DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('mpy.mat', 'DataCell')