function [ zt, lagZt, badZt, lagBadZt,c  ] = generateData( smpSize, phimess )

time = linspace(1,smpSize, smpSize)';
constant1 = unifrnd(0,1, 1,1);
constant2 = unifrnd(3,4,1,1);
coeff1 = unifrnd(0,1, 1,1);
coeff2 = unifrnd(2,3,1,1);
phi = coeff2/coeff1;

mut = normrnd(0,1,smpSize,1);
ept = normrnd(0,1,smpSize,1);

yt = (constant1.*ones(smpSize,1)) + (coeff1.*time) + mut;
xt = (constant2.*ones(smpSize,1)) + (coeff2.*time) + ept;


zt = xt - phi.*yt;
lagZt = zt;
lagZt(1) = [];
zt = zt(1:smpSize-1);

badZt = xt - (phi*phimess .*yt);
lagBadZt = badZt;
lagBadZt(1) = [];
badZt = badZt(1:smpSize-1);

c = ones(smpSize-1,1);

end

