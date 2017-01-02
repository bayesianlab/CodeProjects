clear
clc
% 1%  -4.123, 5% -3.461
dfcrit = -3.461;
sims = 10;
cntG = 0;
cntB = 0;


smpSize = 100;
hold on
lags = 1;
phimess = 1.5;
for i = 1:sims
    [zt,lagzt,badzt,lagbadzt,~] = generateData(smpSize, phimess);
    x = lagOut(lagzt, lags);
    zt = zt(lags + 1:length(zt),1);
    zt = diff(zt);
    x(1,:) = [];
    c = ones(length(zt),1);
    x = [x, c];
    [eG,seG,~, ~,~] = betaLS(x, zt, ones(lags+2,1), .01, 1);
    
    testStatGood = (eG(1) )/seG(1)
    
    ars = lagOut(lagbadzt, lags);
    badzt= badzt(lags+1:length(badzt),1);
    c = ones(length(badzt),1);
    ars = [ars];
    [eB,seB,~,~,~]   = betaLS(ars, badzt, ones(lags+1,1), .01, 1);
    
    testStatBad = (eB(1))/seB(1);
    if testStatGood < dfcrit
        cntG = cntG + 1;
    end
    if testStatBad < dfcrit
        cntB = cntB + 1;
    end
    plot(badzt)
   
end


percentG = cntG/sims;
percentB = cntB/sims;

percentG
percentB
