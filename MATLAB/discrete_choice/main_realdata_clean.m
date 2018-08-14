% Mv probit real data
clear;
clc;
NCountries = 2;
Ik = eye(NCountries);
probit_realdata_import
DATA = table2array(internationalprobitdataset(:,2:9));
Xt = DATA(:,1:6);
[T, ~] =size(Xt);
yt = reshape(DATA(:,7:8), NCountries, T) ;

XtUsa = Xt(:,1:3);
XtCan = Xt(:,4:6);
Temp1 = kron(XtUsa, Ik);
Temp1 = [Temp1(:,1), Temp1(:,3), Temp1(:,5)];
Temp2 = kron(XtCan, Ik);
Temp2 = [Temp2(:,2), Temp2(:,4), Temp2(:,6)];
surX = [Temp1, Temp2];

% yttest = yt(:,1:50)
% surXtest = surX(1:100,:)

mv_probit(yt,surX, eye(NCountries), 100);