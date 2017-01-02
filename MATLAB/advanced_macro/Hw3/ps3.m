clear
clc
%% Import data
ps3Data

%% Create matrix of data
% Adjust size of vectors
can_cpi = can_cpi(1:217); % CPI
can_ind = can_ind(1:217); % Industrial production
can_ir = can_ir(1:217); % Interest rate
uncertainty = uncertainty(1:217); % Uncertainty Index

Y = [uncertainty can_cpi can_ind can_ir]; % Ordering as specified in the problem

%% Estimate VAR

periods = 50;
result = VAR(Y,2,0);
% IRFS
shock = [1;0;0;0];
r = systemResponse(result, shock, periods, 0);
figure(1)
subplot(4,1,1)
plot(r(1,:))
title('Uncertainty')
subplot(4,1,2)
plot(r(2,:))
title('Inflation')
subplot(4,1,3)
plot(r(3,:))
title('Industrial Production')
subplot(4,1,4)
plot(r(4,:))
title('Interest Rates')