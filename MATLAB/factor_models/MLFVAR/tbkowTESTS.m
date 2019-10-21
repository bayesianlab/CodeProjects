clear;clc;
TimeBreakKow(200,  20, '', 'simdata.mat', 'TestDir')
% TimeBreakKow(10,  2, 'BigKow', 'kowz.mat', 'TestDir')
% TimeBreakKow(10, 4, 6, '', 'mpy.mat', 'TestDir')
% TimeBreakKow(10,4,5,'Unemployment', 'ue_big.mat','TestDir')
% TimeBreakKow(10,4,0,'Unemployment', 'worldue.mat','TestDir')

% load('TestDir/Result_simdata_20_Oct_2019_18_33_53.mat')
% sumft = mean(storeFt,3);
% sig = std(storeFt,[],3);
% up=sumft + 2.*sig;
% down = sumft - 2.*sig;
% 
% tf = DataCell{4};
% hold on 
% plot(up(1,:),   'r')
% plot(down(1,:),   'r')
% plot(sumft(1,:), 'black')