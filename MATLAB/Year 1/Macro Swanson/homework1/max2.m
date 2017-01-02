%% Problem Set 1 Question 2
% Econ 210F
% Max Littlejohn

%%
%Question 2 Part A
%load the same data as in question 1, except the data for output and cpi
%will go back to Jan. 1957 because we will need 1st differences
outputVAR12 = xlsread('Industrial Production Data_Jan 1957');  %log-level starts Jan. 1957
cpiVAR12 = xlsread('Core CPI Data'); %log-level starts Jan. 1957
iVAR12 = xlsread('One Year Treasury Data');  %level starts Feb. 1957

%take the first difference of the logged industrial production data and the
%logged cpi data to get the data in log first-differences
outputVAR12 = diff(outputVAR12);
piVAR12 = diff(cpiVAR12);
%industrial production is now in log 1st differences instead of log-levels
%as in question 1

%create the y matrix with the variables as the columns and the rows 
%representing the observations for each period from Feb. 1957 to Feb. 2016
yVAR12 = [outputVAR12 piVAR12 iVAR12];

%using the ols and VAR functions, call the VAR function to obtain the 
%matrix of coefficients(betas) and the variance-covariance matrix for 
%the resids 
%input the y matrix and set p equal to 12
[betaVAR12 LR SSR omega residvarmatrixVAR12 resids] = VAR(yVAR12,12,1);

%% Parts B,C,D
%%

%Need to forecast output growth, inflation and interest rate for March 2016
%Create the X matrix for the first forecast by inputting the last 12
%observations for each variable.
%Must change the OutputVAR12 values from Question 1 because they now need
%to be log 1st differences
XVAR12 = [-.0052 .0028 .53 .0063 .0029 .54 -.0042 .0015 .65 -.0066 .0018 .48 -.001 .002 .26 -.0026 .0019 .37 .00097 .0012 .38 .0058 .0015 .3 -.0016 .0017 .28 -.0023 .0012 .24 -.0023 .0025 .23 -.0032 .002 .25 1];
%March 2016 forecast
forecastVAR12 = XVAR12*betaVAR12;

%Create a loop that forecasts one period ahead starting with april as the
%next period.  December 2016 is nine periods ahead
%Must begin each new looped forecast with the initial X matrix that 
%contains data from Feb 2016 back to March 2015 and the initial forecast 
%for March 2016
XVAR12 = [-.0052 .0028 .53 .0063 .0029 .54 -.0042 .0015 .65 -.0066 .0018 .48 -.001 .002 .26 -.0026 .0019 .37 .00097 .0012 .38 .0058 .0015 .3 -.0016 .0017 .28 -.0023 .0012 .24 -.0023 .0025 .23 -.0032 .002 .25 1];
forecastVAR12 = XVAR12*betaVAR12;
for m=1:9
    for i=4:36
        XVAR12(1,i) = XVAR12(1,i-3);
    end
    for j=1:3
        XVAR12(1,j) = forecastVAR12(1,j); 
    end
    forecastVAR12 = XVAR12*betaVAR12;
end

forecastVAR12

%% Part E
%%

%Need to forecast the "level" of output in March, May, and Dec. 2016 to 
%compare with our output forecasts in question 1.
%Since out questions 2 forecasts are for output growth, we need to start 
%with the level of output in Feb. 2016 and accumulate the amount of
%industrial production each period by adding our forecasted growth rates 
%for each period to the Feb. 2016 output level

%Set initial Feb. 2016 output level
outputlevel_Feb = 4.6665;

%Recalculate March 2016 output growth
XVAR12 = [-.0052 .0028 .53 .0063 .0029 .54 -.0042 .0015 .65 -.0066 .0018 .48 -.001 .002 .26 -.0026 .0019 .37 .00097 .0012 .38 .0058 .0015 .3 -.0016 .0017 .28 -.0023 .0012 .24 -.0023 .0025 .23 -.0032 .002 .25 1];
forecastVAR12 = XVAR12*betaVAR12;

%Add March 2016 forecasted growth to Feb. level to obtain March 2016 level
outputlevel_March = outputlevel_Feb + forecastVAR12(1,1);
%Set outputlevel_March to simply output_level
output_level = outputlevel_March;

%Create a loop that will forecast the same as before, but will then add
%the forecasted output growth for each period to the previous output level
%Make sure to re-initialize the starting XVAR12 vector, forecastVAR12 and 
%output_level for March before running the loop  
XVAR12 = [-.0052 .0028 .53 .0063 .0029 .54 -.0042 .0015 .65 -.0066 .0018 .48 -.001 .002 .26 -.0026 .0019 .37 .00097 .0012 .38 .0058 .0015 .3 -.0016 .0017 .28 -.0023 .0012 .24 -.0023 .0025 .23 -.0032 .002 .25 1];
forecastVAR12 = XVAR12*betaVAR12;
outputlevel_March = outputlevel_Feb + forecastVAR12(1,1);
output_level = outputlevel_March;
for m=1:9
    for i=4:36
        XVAR12(1,i) = XVAR12(1,i-3);
    end
    for j=1:3
        XVAR12(1,j) = forecastVAR12(1,j); 
    end
    forecastVAR12 = XVAR12*betaVAR12;
    output_level = output_level + forecastVAR12(1,1);
end

%Return the forecasted level of output corresponding to the period that is
%entered in the loop above
output_level



