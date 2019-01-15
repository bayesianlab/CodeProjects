clear;clc;
rng(109)
cd '~/CodeProjects/MATLAB/factor_models/KOW/DataGeneratingFiles'
K = 4;
T = 700;
muSim = 0;
betaSim = [-.5, .5, -.5, .5]';
Gsim = [.5, .5, .5, .5]';
gammaSim = .8;
[yt, Xt, Factor] = kowSimDataForTest(K, T, muSim, betaSim, Gsim, gammaSim);
fname = createDateString('sdtest');
save('sdtest.mat')
clear;clc;
