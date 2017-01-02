clear
clc

% null = zeros(2,1);
% alphaLev = .05;
% alt = 2;
% 
% y = normrnd(0,1, 100,1);
% x = normrnd(0,1, 100,1);
% c = ones(100,1);
% 
% a = fitlm(x,y);
% a
% 
% x = [c,x];
% regress(y,x)
% betaLS(x,y, [0;0], .05, 2, 1)
% 
[walk1, walk2, w1Lag, w2Lag, c]= generateWalks( 10 );
% X = [ walk2, c];
% [~, ~, tStats, tCrit] = betaLS( X, walk1, null, alphaLev, ...
%     alt, 0);
% 
% [e, tstat, tcrit] = vreg([walk1, walk2], 1, zeros(3,1), alphaLev, 2,1);
% c = 0;
% for i = 1:100
% [zt, lzt, bz, lbz] = generateData( 1000 );
% [e, se] = betaLS(lbz,bz, 0,.05,1);
% t1 = (e-1)/se;
% if t1 < -2.58
%     c=c+1;
% end
% [e2, se2] = betaLS(zt,lzt,0,.05,1);
% t2 = (e2-1)/se2;
% end
% c
x = linspace(1,10,10)';
a = lagOut(x, 3);
a