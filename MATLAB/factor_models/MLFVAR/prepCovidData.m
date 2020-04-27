clear;clc;
coviddata = covidImport('CovidDataRaw.csv')
logcoviddata = log(coviddata+1);
coviddiffdata = diff(logcoviddata,1,2);
K=102
T = 9
coviddiffdata=(coviddiffdata-mean(coviddiffdata,2))./std(coviddiffdata,[],2);


States = 51;
SeriesPerState = 2;
dimX = (SeriesPerState+1)*SeriesPerState;
colsX = 1:dimX;
X = zeros(K*(T-1),SeriesPerState+1);
fillX = 1:K;
tempX = X(1:K, :);
for t = 1:T-1
    select2 = 1:SeriesPerState;
    select3 = 1:dimX;
    Xrows = fillX + (t-1)*K;
    for c = 1:States
        rows = select2 + (c-1)*SeriesPerState;
        tempX(rows,:) =repmat([1, coviddiffdata(rows, t)'],2,1);
        cols = colsX + (c-1)*dimX;
    end
    X(Xrows,:) = tempX;
end
y = coviddiffdata(:, 2:end);

InfoCell{1} = [1, K];
InfoCell{2} = [1, 18;
    19, 42;
    43, 76;
    76, K];
    

DataCell{1} = y;
DataCell{2} = X;
DataCell{3} = InfoCell;
save('Covid/Covid', 'DataCell')