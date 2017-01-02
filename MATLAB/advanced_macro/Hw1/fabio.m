clear
clc


g1 = [
    .3, 0, 0, 0, 0, 0, 0;
    0, .3, 0, 0, 0, 0, 0;
    0, 0, .8, 0, 0, 0, 0;
    0, 0, 0, .95, 0, 0, 0;
    0, 0, 0, 0, .5, 0, 0;
    0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 1;
    ];

psi = [
    0, 0, 0;
    0, 0, 0;
    0, 0, 1;
    1, 0, 0;
    0, 1, 0;
    0, 0, 0;
    0, 0, 0;
];

pi = [
    0, 0;
    0, 0;
    0, 0;
    0, 0;
    0, 0;
    1, 0;
    0, 1
];

alpha = [0.1, 0.25, 0.5, 0.75, 0.95];

kappa = ((1-alpha(1)) * (1- (.99*alpha(1))) / alpha(1)) * (3.5);
g0 = [
1, 0, .6667, .04286, 0, -.67, -.6667;
-kappa, 1, 0, 0, -1, 0, -.67;
-.025, -.3, 1, 0, 0, 0, 0;
0, 0, 0, 1, 0, 0, 0;
0, 0, 0, 0, 1, 0, 0;
1, 0, 0, 0, 0, 0, 0;
0, 1, 0, 0, 0, 0, 0;
];

[F ,~,G1,~,~,~,~,eu,~] =  gensys(g0,g1,0, psi, pi);
F 
G1
    yt_response_mp = impulse_tech(F, G1, 40, .10);
figure(1)
plot(yt_response_mp(1,:))
title('me')
% IMPULSE RESPONSE FUNCTIONS
% after having run gensys.m

% RE

col = G1(:,1);
periods=40;
for j=1:periods
resp(:,:,j)=col; % Stores the i-th response of the variables to the shocks.
col=F*col; % Multiplies by G1 to give the next step response to the
% shocks.
end
figure(2)
y = squeeze(resp);
plot(y(1,:))
title('fabio')
% resp1y_RE(:,1)=squeeze(resp(1,1,:)); % "squeeze" eliminates the singleton dimensions
% of resp(:,:,:). It returns a matrix with the first ten
% responses of the 1st variable to the 1st shock
% resp2y_RE(:,1)=squeeze(resp(1,2,:));
% resp3y_RE(:,1)=squeeze(resp(1,3,:));
% resp1pi_RE(:,1)=squeeze(resp(2,1,:));
% resp2pi_RE(:,1)=squeeze(resp(2,2,:));
% resp3pi_RE(:,1)=squeeze(resp(2,3,:));
% resp1r_RE(:,1)=squeeze(resp(3,1,:));
% resp2r_RE(:,1)=squeeze(resp(3,2,:));
% resp3r_RE(:,1)=squeeze(resp(3,3,:));

% figure(2)
% subplot(3,1,1)
% plot(1:periods,resp1y_RE(:,1))
% title('Response of Inflation to Monetary Policy shock'); grid on
% subplot(3,1,2)
% plot(1:periods,resp1pi_RE(:,1));
% title('Response of Output Gap to Monetary Policy shock'); grid on
% subplot(3,1,3)
% plot(1:periods,resp1r_RE(:,1));
% title('Response of Federal Funds Rate to Monetary Policy shock'); grid on

% 
% figure(2)
% subplot(3,1,1)
% plot(1:periods,resp2y_RE(:,1))
% title('Response of \pi to u shock'); grid on
% subplot(3,1,2)
% plot(1:periods,resp2pi_RE(:,1));
% title('Response of x to u shock'); grid on
% subplot(3,1,3)
% plot(1:periods,resp2r_RE(:,1));
% title('Response of i to u shock'); grid on
% pause
% 
% figure(3)
% subplot(3,1,1)
% plot(1:periods,resp3y_RE(:,1))
% title('Response of \pi to g shock'); grid on
% subplot(3,1,2)
% plot(1:periods,resp3pi_RE(:,1));
% title('Response of x to g shock'); grid on
% subplot(3,1,3)
% plot(1:periods,resp3r_RE(:,1));
% title('Response of i to g shock'); grid on