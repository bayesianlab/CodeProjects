
clear;clc;
savepath = '~/GoogleDrive/statespace/';
load('UnemploymentMpyResults/Result_worldue_28_Sep_2019_06_02_16.mat')
% load('UnemploymentMpyResults/Result_worldue_01_Oct_2019_10_59_40.mat')
WORLD = [1:K];
DEVELOPED = 1:23; 
EME = 24:47; 
FRONT = 48:66;
OTHER = 67:76;
DNA = 1:2;
DEUR = 3:18;
DPACIFIC = 19:23;
EAMER =  24:29;
EEUR = 30:40;
EASIA = 41:47;
FEUR =48:54;
FAFR= 55:59;
FMIDEAST = 60:63;
FASIA = 64:66;
OAMER = 67:69;
OEUR = 70:74;
OAFR = 75:76;

filevardec= fopen('WueVd/worlduevd.txt', 'w+');
developedvd =  varianceDecomp(DEVELOPED,:);
for j = 1:size(developedvd,1)
    fstr = sprintf('%.2f %.2f %.2f \n', 100*developedvd(j,1), 100*developedvd(j,2), 100*developedvd(j,3));
    fprintf(filevardec, fstr);
end
filevardec= fopen('WueVd/emeuevd.txt', 'w+');
frontvd =  varianceDecomp(EME,:);
for j = 1:size(frontvd,1)
    fstr = sprintf('%.2f %.2f %.2f \n', 100*frontvd(j,1), 100*frontvd(j,2), 100*frontvd(j,3));
    fprintf(filevardec, fstr);
end
filevardec= fopen('WueVd/frontuevd.txt', 'w+');
frontvd =  varianceDecomp(FRONT,:);
for j = 1:size(frontvd,1)
    fstr = sprintf('%.2f %.2f %.2f \n', 100*frontvd(j,1), 100*frontvd(j,2), 100*frontvd(j,3));
    fprintf(filevardec, fstr);
end
filevardec= fopen('WueVd/otheruevd.txt', 'w+');
othervd =  varianceDecomp(OTHER,:);
for j = 1:size(othervd,1)
    fstr = sprintf('%.2f %.2f %.2f \n', 100*othervd(j,1), 100*othervd(j,2), 100*othervd(j,3));
    fprintf(filevardec, fstr);
end

Idens = MakeObsModelIdentity(InfoCell);
Gt = makeStateObsModel(sumOM, Idens, 0);
mu1 = reshape(Xt*sumBeta, K,T);
mu2 = Gt*sumFt;
yhat =  mu1 + mu2;
% hold on 
% plot(yt(1,:))
% plot(yhat(1,:))
% plot(mu1(2,:))
% plot(sumOM(2,1)*sumFt(1, :))
% plot(sumOM(2,2)*sumFt(2, :))
% plot(sumOM(2,3)*sumFt(6, :))
clear;clc;
savepath = '~/GoogleDrive/statespace/';
load('UnemploymentMpyResults/Result_ue_27_Sep_2019_22_39_52.mat')


