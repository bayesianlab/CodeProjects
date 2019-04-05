clear;clc;



housing = importHousing( '~/GoogleDrive/Datasets/pp_long.xlsx', 4, 2, 111);
housing = table2array(housing)';
housinggrowth = log(housing(:,2:end)) - log(housing(:,1:end-1));
InfoCell{1,1} = [1,23];
InfoCell{1,2} = [1,17;...
    18,23];
T = 109;
K = 23;
nCovar= 2;
X = zeros(K*(T-1), nCovar*K);


I = kron(eye(K), ones(1,nCovar));
select = 1:K;
for t = 1:T-1
   put = select +(t-1)*K;
   X(put, :) = I.*repmat([ones(K,1),housinggrowth(:,t)],1,K);
end
X = sparse(X);
y = housinggrowth(:, 2:end);
gg=full(X)
DataCell = cell(1,7);
DataCell{1,1} = y;
DataCell{1,2} = X;
DataCell{1,3} = InfoCell;
DataCell{1,4} = 0;
DataCell{1,5} = 0;
DataCell{1,6} = 0;
DataCell{1,7} = 0;
save('Housing.mat', 'DataCell')