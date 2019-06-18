clear;clc;
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

Indx = 75:125;
mkdir('TimeBreakData')
for i = Indx
    yte = yt(:, 1:i);
    Xte = Xt(1:K*i, :);
    fnamee = sprintf('TimeBreakData/TimeBreakEnd%i',i);
    ytb = yt(:,i+1:end);
    Xtb = Xt(K*i + 1:end,:);
    fnameb = sprintf('TimeBreakData/TimeBreakBeg%i',i+1);
    save(fnamee, 'yte','Xte', 'InfoCell')
    save(fnameb, 'ytb', 'Xtb', 'InfoCell')
end