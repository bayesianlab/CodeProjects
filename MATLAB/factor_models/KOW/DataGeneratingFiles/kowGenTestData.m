clear;clc;

cd '~/CodeProjects/MATLAB/factor_models/KOW/DataGeneratingFiles'
K = 4;
T = 500;
muSim = .2;
betaSim = [1, -1, 1, -1]';
Gsim = [.5, .5, .5, .5]';
gammaSim = .8;
[yt, Xt, Factor, Beta] = kowSimDataForTest(K, T, muSim, betaSim, Gsim, gammaSim);
fname = createDateString('sdtest');
save('sdtest.mat')

