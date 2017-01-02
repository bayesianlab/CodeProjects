function [ zt, lagZt, badZt, lagBadZt, spur, c  ] = generateData( smpSize )

time = linspace(1,smpSize, smpSize)';
constants = unifrnd(0,1, 2,1);
coeffs = unifrnd(0,1, 2,1);
phi = coeffs(2)/coeffs(1);

mut = normrnd(0,1,smpSize,1);
ept = normrnd(0,1,smpSize,1);

yt = (constants(1).*ones(smpSize,1)) + (coeffs(1).*time) + mut;
xt = (constants(2).*ones(smpSize,1)) + (coeffs(2).*time) + ept;
eye0 = normrnd(0,1,smpSize,1);

% drift = constants(2) - phi*constants(1);

zt = xt - phi.*yt;
lagZt = zt;
lagZt(1) = [];
zt = zt(1:smpSize-1);

badZt = xt -  ((-5) .*yt);
lagBadZt = badZt;
lagBadZt(1) = [];
badZt = badZt(1:smpSize-1);
c = ones(smpSize-1);

spur = xt - phi.*eye0;
spur(1) = [];




end

