%% Homework 6 Question 2 
% Part B
% Max Littlejohn and Andy Zanazanian
%%
clear 
clc
%Size of sample observations
T = 50;
%Number of Monte Carlo Iterations
I = 100;
ADFcritical = -3.44;

%The series take the forms of x_t = alpha + beta*t + e and 
%y_t = delta + gamma*t + u which are both I(1) by construction
%t is a trend vector which will take on values from 1-100

%Create vectors to store the values of x and y
x_t = zeros(T,1);
y_t = zeros(T,1);

%Create the trend vector, use linspace, faster.
trend = linspace(1,T,T)';

%Specify the values for the two constants alpha and delta
alpha = 1.125;
delta = 2.0;
%Specify the values for the coefficients on the trend vector, beta and
%gamma
beta = 0.6;
gamma = 0.6;

%Create a vector to store the Augmented Dickey Fuller test statistics
ADFstat_vector = [];
%Loop 
rejects = 0;
for i = 1:I
    mu = normrnd(0,1,T,1);  
    eps = normrnd(0,1, T, 1);
    unos = ones(T,1);
    % Do in one shot, faster
    x_t = (alpha.*unos) + (beta.*trend) + mu;  %this vector was linearized by 0.75 scalar
    y_t = delta.*unos + gamma.*trend + eps;
    
    betaOLS = (x_t'*x_t)\(x_t'*y_t);
    resid_vector = y_t - (x_t*betaOLS);
    
    % your way had a zero there, in first element
    lagged_resid = resid_vector(1:T-1,1);
    % use diff
    rsdDiff = diff(resid_vector);
        
    betaADF = (lagged_resid'*lagged_resid)\((lagged_resid'*rsdDiff));
    e = rsdDiff - (betaADF*lagged_resid);
    ser = sqrt((sum(e.^2))/(T-2));
    
    tstat_ADF = (betaADF-1)/ser;
    if tstat_ADF < ADFcritical
        rejects = rejects + 1;
    end
end
rejects/ I
ADFstat_vector = ADFstat_vector';


% 
% figure ;
% plot(trend,resid_vector);
    