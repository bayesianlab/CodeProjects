% clear;clc;
% rng(9)
% timeBreak = 100;
% T = 200;
% K =10;
% MLFtimebreaks(K, T, timeBreak);
% load('TimeBreakSimData/totaltime.mat')
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% 
% Indx = 70:130;
% for i = Indx
%     yte = yt(:, 1:i);
%     Xte = Xt(1:K*i, :);
%     fnamee = sprintf('TimeBreakSimData/TimeBreakEnd%i',i);
%     ytb = yt(:,i+1:end);
%     Xtb = Xt(K*i + 1:end,:);
%     fnameb = sprintf('TimeBreakSimData/TimeBreakBeg%i',i+1);
%     DataCell{1,1} = yte;
%     DataCell{1,2} = Xte;
%     DataCell{1,3} = InfoCell;
%     save(fnamee, 'DataCell')
%     DataCell{1,1} = ytb;
%     DataCell{1,2} = Xtb;
%     save(fnameb, 'DataCell')
% end

clear;clc;
load('BigKow/kow_raw.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
[K,T] = size(yt);
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};

Indx = 15:45;
if ~exist('TimeBreakDataKOW', 'dir')
    mkdir('TimeBreakDataKOW')
end
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

% load('MpyData/mpy.mat')
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% [K,T] = size(yt);
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% 
% Indx = 5:45;
% if ~exist('TimeBreakDataMPY', 'dir')
%     mkdir('TimeBreakDataMPY')
% end
% for i = Indx
%     yte = yt(:, 1:i);
%     Xte = Xt(1:K*i, :);
%     fnamee = sprintf('TimeBreakDataMPY/TimeBreakMPYEnd%i',i);
%     ytb = yt(:,i+1:end);
%     Xtb = Xt(K*i + 1:end,:);
% 
%     fnameb = sprintf('TimeBreakDataMPY/TimeBreakMPYBeg%i',i+1);
%     DataCell{1,1} = yte;
%     DataCell{1,2} = Xte;
%     DataCell{1,3} = InfoCell;
%     save(fnamee, 'DataCell')
%     DataCell{1,1} = ytb;
%     DataCell{1,2} = Xtb;
%     save(fnameb, 'DataCell')
% end
