clear
clc
% Fixed params
beta = 0.9;
gamma = 2;
z_2 = 1.10;
p_22 = 0.1;
power = 1- gamma;

% Variable params
p_11 = [.2 .8];
z_1 = [1 1.10];

% Construct Matrix 1 p = .2 z_1 = 1
g_hat_matrix1= constructMatrix(z_1(1,1), z_2,p_11(1,1)...
    ,p_22, power,beta);

% Select Row one of g_hat_matrix
g_1 = g_hat_matrix1(1,:);

% Set up consumption vector
maxConsumption = 20000;
initialConsumption = 100;
step = 0.10;
consumption = initialConsumption:step:maxConsumption;
value1 = zeros(length(consumption), 1);
counter = 0;
for consumption = initialConsumption:step:maxConsumption
    counter = counter + 1;
    value1(counter,1) = sum(crraUtility(consumption, power, power)...
        .* g_1);
end

% Construct Matrix 2 p = .8 z = 1.10
g_hat_matrix2= constructMatrix(z_1(1,2), z_2,p_11(1,2)...
    ,p_22, power,beta);

% Select Row one of g_hat_matrix
g_12 = g_hat_matrix2(1,:);

value2 = zeros(length(consumption), 1);
counter = 0;
for consumption = initialConsumption:step:maxConsumption
    counter = counter + 1;
    value2(counter,1) = sum(crraUtility(consumption, power, power)...
        .* g_12);
end

% Construct Matrix 3 p = .8 z = 1.00
g_hat_matrix3 = constructMatrix(z_1(1,1), z_2,p_11(1,2)...
    ,p_22, power,beta);
row11 = g_hat_matrix3(1,:);

% Set up consumption for plot
value3 = zeros(length(consumption), 1);
counter = 0;
for consumption = initialConsumption:step:maxConsumption
    counter = counter + 1;
    value3(counter,1) = sum(crraUtility(consumption, power, power)...
        .* row11);
end

% Construct Matrix 4 p = .8 z = 1.10
g_hat_matrix3 = constructMatrix(z_1(1,2), z_2,p_11(1,2)...
    ,p_22, power,beta);
row12 = g_hat_matrix3(1,:);

% Set up consumption for plot
value4 = zeros(length(consumption), 1);
counter = 0;
for consumption = initialConsumption:step:maxConsumption
    counter = counter + 1;
    value4(counter,1) = sum(crraUtility(consumption, power, power)...
        .* row12);
end

figure
plot(value1)
hold on
plot(value2)
legend('p = .2 z_1 = 1','p = .2 z = 1.10','Location', 'southeast')
title('Plot of Probability Set to .2  z_1 \in 1.00, 1.10')

figure
plot(value3)
hold on
plot(value4)
legend('p = .8 z = 1.00', 'p = .8 z = 1.10', 'Location', 'southeast')
title('Plot of Probability Set to .8 z_1 \in \{1.00, 1.10\}')

%% Intuition of Results
%  Examining the matrix g we see the intuition behind the graphs.
%  As entry 1,1 increases in p the entry in 1,2 become closer in 
% value. We would expect an increase in p to cause the graphs of the
% value function to be closer to identical than the case where p is
% low. The emprical results bear this out. When p = .8 the lines converge
% more quickly than the corresponding case for p=.2 for both values
% of z. 
