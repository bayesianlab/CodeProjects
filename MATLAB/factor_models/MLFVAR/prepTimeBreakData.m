clear;clc;
rng(3)
timeBreak = 100;
T = 200;
K =6;
identification = 2;
MLFtimebreaks(K, T, timeBreak, identification);
load('totaltime.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};

Indx = 40:160;
mkdir('TimeBreakData')
for i = Indx
    yte = yt(:, 1:i);
    Xte = Xt(1:K*i, :);
    fnamee = sprintf('TimeBreakData/TimeBreakEnd%i',i);
    ytb = yt(:,i+1:end);
    Xtb = Xt(K*i + 1:end,:);
    fnameb = sprintf('TimeBreakData/TimeBreakBeg%i',i+1);
    DataCell{1,1} = yte;
    DataCell{1,2} = Xte;
    DataCell{1,3} = InfoCell;
    save(fnamee, 'DataCell')
    DataCell{1,1} = ytb;
    DataCell{1,2} = Xtb;
    save(fnameb, 'DataCell')
end

load('StandardizedRealData.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
[K,T] = size(yt);
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};

Indx = 5:50;
mkdir('TimeBreakDataKOW')
for i = Indx
    yte = yt(:, 1:i);
    Xte = Xt(1:K*i, :);
    fnamee = sprintf('TimeBreakDataKOW/TimeBreakKowEnd%i',i);
    ytb = yt(:,i+1:end);
    Xtb = Xt(K*i + 1:end,:);

    fnameb = sprintf('TimeBreakDataKOW/TimeBreakKowBeg%i',i+1);
    DataCell{1,1} = yte;
    DataCell{1,2} = Xte;
    DataCell{1,3} = InfoCell;
    save(fnamee, 'DataCell')
    DataCell{1,1} = ytb;
    DataCell{1,2} = Xtb;
    save(fnameb, 'DataCell')
end