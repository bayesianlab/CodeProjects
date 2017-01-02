%% Problem Set 1 Question 1
% Econ 210F
% Max Littlejohn

%%
%Question 1 Part A
%Load the data from Feb. 1957 to Feb. 2016
%The data for output and cpi were downloaded in log-levels so there is no
%no need to convert them to log-levels after uploading them
clear 
clc
output = xlsread('INDPRO');   %log-level
cpi = xlsread('cpi'); %log-level starts in Jan. 1957
i = xlsread('t_bonds');    %level

%Plot the raw data on three separate plots to make sure it looks correct 
%without any missing data 
figure
subplot(3,1,1)
plot(output,'-b')
title('Raw Industrial Production Data (Log-Levels)')
subplot(3,1,2)
plot(cpi,'-r')
title('Raw Core CPI Data (Log-Levels)')
subplot(3,1,3)
plot(i,'-g')
title('Raw Maturity Rate Data (Levels)')
%The data looks correct

%Trim the data so it goes from Dec. 1957 to Feb. 2016 for VAR(2) with two 
%lags back.  The data for cpi will go back to Nov. 1957
outputVAR2 = output(11:709,1); 
cpiVAR2 = cpi(11:710,1);
iVAR2 = i(11:709,1);

%Take the first difference of the logged cpi data to get inflation
piVAR2 = diff(cpiVAR2);

%Create the y matrix with the variables as the columns and the rows 
%representing the observations for each period from Dec. 1957 to Feb. 2016
y = [outputVAR2 piVAR2 iVAR2];

%Using the ols and VAR functions, call the VAR function to obtain the 
%matrix of coefficients(betas) and the variance-covariance matrix for 
%the residuals 
%Input the y matrix and set p equal to 2
[beta LR SSR omega residvarmatrix resids] = VAR_Swan(y,2,1);

%% Parts B,C,D
%%
%need to forecast output, inflation and interest for March 2016
%create the initial X matrix for the first forecast
X = [4.6665 0.0028 0.53 4.6715 .0029 .54 1];
%March 2016 forecast
forecast = X*beta;

%create a loop that forecasts one period ahead starting with april as the
%next period.  December 2016 is nine periods ahead
%must begin each new looped forecast with the initial X matrix that 
%contains Feb. and Jan. 2016 data and the initial forecast for March 2016
X = [4.6665 0.0028 0.53 4.6715 .0029 .54 1];
forecast = X*beta;
for m=1:9              %9 periods will take us from March to Dec.
    for i=4:6
        X(1,i) = X(1,i-3);
    end
    for j=1:3
        X(1,j) = forecast(1,j); 
    end
    forecast = X*beta;
end

forecast

%% Part E
%%
%load the data from Feb. 1957 to Feb. 2016
outputVAR12 = xlsread('Industrial Production Data');
cpiVAR12 = xlsread('Core CPI Data'); %starts in Jan. 1957
iVAR12 = xlsread('One Year Treasury Data');

%take the first difference of the logged cpi data to get inflation
piVAR12 = diff(cpiVAR12);

%create the y matrix with the variables as the columns and the rows 
%representing the observations for each period from Feb. 1957 to Feb. 2016
yVAR12 = [outputVAR12 piVAR12 iVAR12];

%using the ols and VAR functions, call the VAR function to obtain the 
%matrix of coefficients(betas) and the variance-covariance matrix for 
%the resids 
%input the y matrix and set p equal to 12
[betaVAR12 LR SSR omega residvarmatrixVAR12 resids] = VAR(yVAR12,12,1);

%% Parts F,G,H
%%

%need to forecast output, inflation and interest rate for March 2016
%create the X matrix for the first forecast
XVAR12 = [4.6665 .0028 .53 4.6715 .0029 .54 4.6638 .0015 .65 4.6685 .0018 .48 4.6760 .002 .26 4.6774 .0019 .37 4.6775 .0012 .38 4.6773 .0015 .3 4.6697 .0017 .28 4.6698 .0012 .24 4.6734 .0025 .23 4.6751 .002 .25 1];
%March 2016 forecast
forecastVAR12 = XVAR12*betaVAR12;

%create a loop that forecasts one period ahead starting with april as the
%next period.  December 2016 is nine periods ahead
%must begin each new looped forecast with the initial X matrix that 
%contains data from Feb 2016 back to March 2015 and the initial forecast 
%for March 2016
XVAR12 = [4.6665 .0028 .53 4.6715 .0029 .54 4.6638 .0015 .65 4.6685 .0018 .48 4.6760 .002 .26 4.6774 .0019 .37 4.6775 .0012 .38 4.6773 .0015 .3 4.6697 .0017 .28 4.6698 .0012 .24 4.6734 .0025 .23 4.6751 .002 .25 1];
forecastVAR12 = XVAR12*betaVAR12;
for m=1:2
    for i=4:36
        XVAR12(1,i) = XVAR12(1,i-3);
    end
    for j=1:3
        XVAR12(1,j) = forecastVAR12(1,j); 
    end
    forecastVAR12 = XVAR12*betaVAR12;
end

forecastVAR12









