function [ rWalk1, rWalk2, rWalk1_lag, rWalk2_lag, c ] = generateWalks( smpSize )


drift = unifrnd(-1,1,2,1);
wn = normrnd(0,1,2,1);
walkLen = zeros(smpSize,1);
rWalk1 = vertcat(wn(1), walkLen);
rWalk2 = vertcat(wn(2), walkLen); 
for i = 1: smpSize
    rWalk1(i+1, 1) = rWalk1(i,1) + drift(1) + normrnd(0,1);
    rWalk2(i+1, 1) = rWalk2(i,1) + drift(2) + normrnd(0,1);
end

rWalk1_lag = rWalk1(1:smpSize, 1);
rWalk2_lag = rWalk2(1:smpSize, 1);
rWalk1(1) = [];
rWalk2(1) = [];
c = ones(smpSize,1);

end

