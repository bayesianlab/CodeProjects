function [ avg_ests ] = vregMc( input_args )

store = zeros(3,2,nSims);
for i = 1:nSims
    [ rWalk1, rWalk2, rWalk1_lag, rWalk2_lag, c ] = generateWalks( smpSize);
    dMat = [rWalk1, rWalk2];
    estimators = vreg(dMat,1,0);
    store(:,:,i) = estimators;
end

avg_ests = mean(store, 3);
end

