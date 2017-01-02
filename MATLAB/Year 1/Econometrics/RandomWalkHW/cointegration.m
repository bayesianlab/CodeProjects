clear
clc
% 1%  -4.123, 5% -3.461
dfcrit = -4.123;
sims = 50;
cntG = 0;
cntB = 0;
cntS = 0;

smpSize = 25;
hold on
for i = 1:sims
    [zt,lagzt,badzt,lagbadzt, spur, c ] = generateData(smpSize);
    [e,se,~, ~,~] = betaLS(lagzt, zt, 1, .01, 1);
    testStatGood = (e-1)/se;
    [e,se,~,~,~]   = betaLS(lagbadzt, badzt, 1, .01, 1);
    testStatBad = (e-1)/se;
    [e,se,~,~,~]   = betaLS(spur, zt, 1, .01, 1);
    testStatSpur =(e-1)/se;
    if testStatGood < dfcrit
        cntG = cntG + 1;
    end
    if testStatBad < dfcrit
        cntB = cntB + 1;
    end
    if testStatSpur < dfcrit
         cntS = cntS + 1;
    end
    plot(spur)
%     plot(zt)
%     plot(badzt)
end
generateData( smpSize );

percentG = cntG/sims;
percentB = cntB/sims;
percentS = cntS/sims;
percentG
percentB
percentS