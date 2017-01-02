function [  ] = varMC( nSims, smpSize )
null = zeros(3,1);
altEnum = 2;
ci = .05;

storeR = zeros(3,2,nSims);
storeD = zeros(3,2,nSims);

for i = 1:nSims
    [ rWalk1, rWalk2, ~, ~, ~ ] = generateWalks( smpSize );
    dWalk1 = diff(rWalk1);
    dWalk2 = diff(rWalk2);
    
    rMat = [rWalk1, rWalk2];
    dMat = [dWalk1, dWalk2];
    [estimatorsR, t] = vreg(rMat, 1, null, ci, altEnum, 0);
    [estimatorsD, t] = vreg(dMat, 1, null, ci, altEnum, 0);
    storeD(:,:,i) = estimatorsD;
    storeR(:,:,i) = estimatorsR;
end
nbins = 15;

figure
subplot(2,1,1)
histogram(storeR(2,1,:), nbins)
str = sprintf('Sampling Distribution %i obs', smpSize);
title(str)
subplot(2,1,2)
histogram(storeR(3,1,:), nbins)

figure
subplot(2,1,1)
histogram(storeD(2,1,:))
str = sprintf('Sampling Distribution %i obs', smpSize);
title(str)
subplot(2,1,2)
histogram(storeD(3,1,:))

str = sprintf( 'Mean %i obs, cointegrated', smpSize);
disp(str)
disp(mean(storeR,3))
str = sprintf( 'Mean %i obs, differenced', smpSize);
disp(str)
disp(mean(storeD,3))

str = sprintf( 'Standard Deviation %i cointegrated', smpSize);
disp(str)
disp( std(storeR, 0, 3) )
str = sprintf( 'Standard Deviation %i differenced', smpSize);
disp(str)
disp( std(storeD, 0, 3) )
end

