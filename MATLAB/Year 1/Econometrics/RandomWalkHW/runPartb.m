clear
clc

smpSize = [
    10;
    100;
    1000;
    ];
nSims = 250;

for smp =  1 : length(smpSize)
    varMC(nSims, smpSize(smp))
end

