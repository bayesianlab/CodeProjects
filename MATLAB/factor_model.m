% Dgp 
clear;clc;

sigma2 = 1;
gamma = .5;
T = 1000;
D = eye(2);
Om = createSigma(-.3, 4);
ft = zeros(2,T);
fV = (1/(1-(gamma*gamma))).*D;
ft(:,1) = mvnrnd(zeros(2,1),D);
yt = zeros(4,T);
yt(:,1) = mvnrnd(zeros(4,1), Om);

G = [.1, -.1, .3, -.3; 
    -.4, .1, .3, .2;
    .4, 0, .2, -.4;
    .3, 0, -.2, .3];

A = [1, 0,0,0;
    .2, 1, 0,0;
    .4, .3,0,0;
    -.3, .2, 0,0];

for t = 2:T
    ft(:,t) = mvnrnd(zeros(2,1), D) + ft(:,t-1)';
    yt(:,t) = G*yt(:,t-1) + A*[ft(:,t);0;0] + mvnrnd([0,0,0,0], Om)';
end
plot(yt')
