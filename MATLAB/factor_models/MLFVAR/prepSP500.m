clear;clc;
weeklyReturns = importSP500("~/GoogleDrive/Datasets/weeklyReturns.csv", 1, 470);

weeklyReturns = table2array(weeklyReturns);

[K, T ]= size(weeklyReturns);
InfoCell{1,1} = [1,K] ;
InfoCell{1,2} = [1, 76;
    77, 108;
    109, 139;
    140, 201;
    202, 259;
    260, 323;
    324, 385;
    386,408;
    409, 440;
    441, 443;
    444, 470];

SeriesPerCountry = 1;
Countries = 470;

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
        tempX(rows,cols)= kron(eye(SeriesPerCountry), [1, weeklyReturns(rows, t)']);
    end
    X(Xrows, :) = tempX;
end
X = sparse(X);
y = weeklyReturns(:, 2:end);

DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('weeklyReturns.mat', 'DataCell')