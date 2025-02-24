clear;clc;
ue = importfileue('~/GoogleDrive/Datasets/US unemployment/ue_ordered.csv', 290, 519 );
importdates
ue = table2array(ue)';
ue = log(ue(:,2:end)) - log(ue(:, 1:end-1));
ue = ue - mean(ue,2);
ue = ue./std(ue,[],2);
[K,T] = size(ue);
SeriesPerCountry = 1;
Countries = 50;
InfoCell{1,1} = [1,K];
InfoCell{1,2} = [1,13; 14,25; 26,40; 41,50];

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
        tempX(rows,cols)= kron(eye(SeriesPerCountry), [1, ue(rows, t)']);
    end
    X(Xrows, :) = tempX;
end
X = sparse(X);
y = ue(:,2:T);

DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('Unemployment/ue_big.mat', 'DataCell')
