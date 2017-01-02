function [ percentSpurious] = rWalkMC( smpSize, repetitions )



null = zeros(2,1);
alphaLevel = .05;
alternative = 2;

spurious = 0;
for i = 1:repetitions
    [walk1, walk2, w1Lag, w2Lag, c]= generateWalks( smpSize );
    X = [ walk2, c];
    [~, ~, tStats, tCrit] = betaLS( X, walk1, null, alphaLevel, ...
        alternative, 0);
    % T stat on w2Lag should be insignificant
    if abs(tStats(1)) > abs(tCrit)
        spurious = spurious + 1;
    end
end
percentSpurious = spurious/ repetitions ;

end

