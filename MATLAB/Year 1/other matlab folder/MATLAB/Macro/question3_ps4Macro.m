%% question3_ps4
clear 
clc

% Params
beta = 0.9;
gamma = 2;
z_2 = 1.10;
p_22 = 0.9;
power = 1 - gamma;

% p_11 Defined 
p_11 = [.2; .8];
z_1 =  1.03;

% Expected Value calculations, calculated using the stationary 
% distribtuion and the given values for z.
expectedValues = [1.092; 1.0767];
    
% Diagonal Matrix
diag1 = [z_1^power 0; 0 z_2^power];

% Markov Transition Matrix
transitionMat1 = [(1/9) 8/9; 1/9 8/9];
transitionMat2 = [1/3 2/3; 1/3 2/3];

% All multiplied together created by funciton createMatrixG
matrixG11 = createMatrixG(transitionMat1, diag1, beta);
matrixG21 = createMatrixG(transitionMat2, diag1, beta);


% The only needed elements of above. 
g11 = matrixG11(1,1);
g12 = matrixG21(1,1);


omega_11 = genOmega(expectedValues(1,1), g11, beta,...
    power)
omega_12 = genOmega(expectedValues(2,1), g12, beta,...
    power)






