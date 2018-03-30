clear;
clc;
% file = '/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/build/yt.txt';
% yt = importdata(file);
phi1 = 1.4;
phi2 = -.8;
phi3 = .9;
phi4 = -.3;

N = 1000;
yt(1,1) = -1;
yt(1,2) = 5;

for i = 2:N
   yt(i,1) =   1 + phi1*yt(i-1,1) + phi2*yt(i-1,2) + normrnd(0,1); 
   yt(i,2) =  .3  + phi3*yt(i-1,1) + phi4*yt(i-1, 2) + normrnd(0,1);
end

% VAR_Swan(yt, 1)

Sigma = createSigma(-.7, 3)
chol(Sigma, 'lower')
for j = 1:10
c = 0;
for i = 1: 100
    w = wishrnd(Sigma,10);
    if w(1,1) > 20
        c = c + 1;
    end
end
disp(c/100)
end