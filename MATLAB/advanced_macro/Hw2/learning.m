function [ difference, expectationsXtPlus1 ] = learning( R_init, Phi_init, gain, x,...
    expectationsSurvey)

time = length(x);
phis = zeros(2,time);
Rs = zeros(2,2,time);
expectationsXtPlus1 = zeros(time,1);

phis(:,1) = Phi_init;
Rs(:,:,1) = R_init;

for t = 2:time
    z = [1, x(t-1)]';
    gzzpMinusR = gain*( z * z'  - Rs(:,:,t-1) );
    Rs(:, :, t) = Rs(:, :, t-1) + gzzpMinusR;
    
    gRinvZ = gain * (Rs(:,:,t)^(-1)) * z;
    xMinusPhiZ = (x(t) - (phis(:, t-1)' * z))';
    phis(:, t) = phis(:, t-1) + (gRinvZ * xMinusPhiZ);
    
    expectationsXtPlus1(t) = phis(1,t) * (1 + phis(2,t))  +...
        (phis(2,t)^2) * x(t-1);
end
expectationsXtPlus1(1) = x(1);
difference = gainDifference(expectationsSurvey, expectationsXtPlus1);
