%% Homework 6 Question 2 
% Part B
% Max Littlejohn and Andy Zanazanian
%%

%Size of sample observations
T = 50;
%Number of Monte Carlo Iterations
I = 1000;

%The series take the forms of x_t = alpha + beta*t + e and 
%y_t = delta + gamma*t + u which are both I(1) by construction
%t is a trend vector which will take on values from 1-100

%Create vectors to store the values of x and y
x_t = zeros(T,1);
y_t = zeros(T,1);

%Create the trend vector
trend = zeros(T,1);
for i = 1:T;
    trend(i,1) = i;
end

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
for i = 1:I;
    for j = 1:T;
        x_t(j,1) = alpha + beta*trend(j,1) + (0.75)*normrnd(0,1);  %this vector was linearized by 0.75 scalar
    end
    for l = 1:T;
        y_t(l,1) = delta + gamma*trend(l,1) + normrnd(0,1);
    end
    betaOLS = (x_t'*x_t)\(x_t'*y_t);
    resid_vector = y_t - (x_t*betaOLS);
    lagged_resid = zeros(T,1);
        for m = 2:T;
            lagged_resid(m,1) = resid_vector(m-1,1);
        end
    
    resid_difference = [resid_vector(1,1) zeros(T-1,1)'];
    resid_difference = resid_difference';
        for k = 2:T;
            resid_difference(k,1) = resid_vector(k,1) - resid_vector(k-1,1);
        end
        
    betaADF = (lagged_resid'*lagged_resid)\((lagged_resid'*resid_difference));
    e = resid_difference - (betaADF*lagged_resid);
    ser = sqrt((sum(e.^2))/(T-2));
    tstat_ADF = (betaADF-1)/ser;
    ADFstat_vector = [ADFstat_vector, tstat_ADF];
end

ADFstat_vector = ADFstat_vector';

%Need to calculate the acceptance rate
%First, create an empty count vector and specify critical value for the ADF
%test at the 99% confidence level
ADFcritical = -3.44;
count = zeros(1,I);


for i = 1:I;
    if ADFstat_vector(i,1) < ADFcritical;
        count(1,i) = 1;
    else
        count(1,i) = 0;
    end
end

    

e = resid_difference - betaADF*lagged_resid;
ser = sqrt((sum(e.^2)/T-2));
tstat_ADF = (betaADF)/ser;


figure 
plot(trend,resid_vector)
    