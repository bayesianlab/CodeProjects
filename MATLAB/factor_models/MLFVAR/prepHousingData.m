clear;clc;

import_housing
statehousing = table2array(statehousing);
[K,T] = size(statehousing);

InfoCell{1,1} = [1,147];
InfoCell{1,2} = [(1:3:147)',(3:3:147)'];

statehousing = statehousing./std(statehousing,0,2);
statehousing = statehousing - mean(statehousing,2);

nCovar = 4;
seriesPerState = 3;
states = 49;
X = zeros(K*(T-1),  nCovar*K);
tempX = X(1:K, :);
dimX = seriesPerState*nCovar;
colsX = 1:dimX;
I = kron(eye(K), ones(1,nCovar));
select = 1:K;

for t = 1:T-1
   select2 = 1:seriesPerState;
   put = select +(t-1)*K;
   for c = 1:states
        rows = select2 + (c-1)*seriesPerState;
        cols =  colsX + (c-1)*dimX;
        tempX(rows,cols)= kron(eye(seriesPerState), [1, statehousing(rows, t)']);
    end
X(put, :) = tempX;
end
X = sparse(X);
y = statehousing(:, 2:end);

DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('State_Housing.mat', 'DataCell')