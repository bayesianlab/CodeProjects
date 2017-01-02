clc
clear all

[YEAR,QUARTER,deltayt,expectationsFutureY,pit,expectationsFuturePi,...
    it,expectationsFuturei] = ...
    importfile('PS2data.xlsx','Sheet1',1,192); 

T = 140; 
phi_0 = [0, 0.5]'; 
R_0 = eye(2); 
it = it(52:length(it),1);
expectationsFuturei = expectationsFuturei(52:length(expectationsFuturei),1);

% Part i output
figure(1)
bestGainY = gainBestFit(R_0, phi_0, deltayt, expectationsFutureY, 75,1);
% Part i inflation
figure(2)
bestGainPi = gainBestFit(R_0, phi_0, pit, expectationsFuturePi, 75,1);
% Part i interest rates
figure(3)
bestGaini = gainBestFit(R_0, phi_0, it, expectationsFuturei, 75,1);

% Part ii output, inflation, interest rates
[~, expectationsXtPlus1] = learning(R_0, phi_0, bestGainY, deltayt,...
    expectationsFutureY);
[~, expectationsPi] = learning(R_0, phi_0, bestGainPi, pit,...
    expectationsFuturePi);
[~, expectationsi] = learning(R_0, phi_0, bestGaini, it,...
    expectationsFuturei);

% Graphs for part ii
figure(4)
hold on
plot(expectationsFutureY)
plot(expectationsXtPlus1)
hold off

figure(5)
hold on 
plot(expectationsFuturePi)
plot(expectationsPi)
hold off

figure(6)
hold on 
plot(expectationsFuturei)
plot(expectationsi)
hold off

% Three subsamples and changes in best-fit gains
[r,c] = size([deltayt, pit]);
nineteen83q4 = 61;
twothousand7q2 = 155;
periodA = 1:nineteen83q4;
periodB = (nineteen83q4+1):twothousand7q2;
periodC = (twothousand7q2+1):r;

ySub1 = deltayt(periodA, 1);
ySub2 = deltayt(periodB, 1);
ySub3 = deltayt(periodC, 1);
eYA = expectationsFutureY(periodA, 1);
eYB = expectationsFutureY(periodB, 1);
eYC = expectationsFutureY(periodC, 1);

% Best gain output
figure(7)
hold on 
bestGainYA = gainBestFit(R_0, phi_0, ySub1, eYA, 75,1);
bestGainYB = gainBestFit(R_0, phi_0, ySub2, eYB, 75,1);
bestGainYC = gainBestFit(R_0, phi_0, ySub3, eYC, 75,1);
hold off

piA = pit(periodA, 1);
piB = pit(periodB, 1);
piC = pit(periodC, 1);
ePiA = expectationsFuturePi(periodA,1);
ePiB = expectationsFuturePi(periodB,1);
ePiC = expectationsFuturePi(periodC,1);

% Best gain inflation
figure(8)
hold on 
bestGainYA = gainBestFit(R_0, phi_0, piA, ePiA, 75,1);
bestGainYB = gainBestFit(R_0, phi_0, piB, ePiB, 75,1);
bestGainYC = gainBestFit(R_0, phi_0, piC, ePiC, 75,1);
hold off


