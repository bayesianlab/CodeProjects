clear;clc;
probity=import_probity();
spx = import_spx();


Xt = table2array( spx(:,2:end) );
yt = table2array( probity(:,2:end) )';

yt = yt(:, 1035:1214);
Xt = Xt(1035:1214,1:3);
[K,T] = size(yt) ;
Xt = [ones(T,1), Xt];
Xt = kron(Xt,ones(K,1));

InfoCell{1} = [1,11];

DataCell{1} = yt;
DataCell{2} = Xt;
DataCell{3} = InfoCell;
save('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp1', 'DataCell')

InfoCell{1} = [1,11];
InfoCell{2} = [2,11];

DataCell{1} = yt;
DataCell{2} = Xt;
DataCell{3} = InfoCell;
save('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp2', 'DataCell')

InfoCell{1} = [1,11];
InfoCell{2} = [2,11];
InfoCell{3} = [3,11];

DataCell{1} = yt;
DataCell{2} = Xt;
DataCell{3} = InfoCell;
save('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp3', 'DataCell')

InfoCell{1} = [1,11];
InfoCell{2} = [2,11];
InfoCell{3} = [3,11];
InfoCell{4} = [4,11];

DataCell{1} = yt;
DataCell{2} = Xt;
DataCell{3} = InfoCell;
save('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp4', 'DataCell')

