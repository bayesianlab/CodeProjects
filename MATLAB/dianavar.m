%% Question 1 Part a
clear
clc

% [t, pi]  = import_fred_data('CPI.csv', 1,719);
% [t, int] = import_fred_data('BOND1.csv', 1,719);
% [t, y]   = import_fred_data('IPI.csv', 1,719);
% l=719;
% log_y = log(y);
% log_y = log_y(2:l)
% log_pi = log(pi);
% int = int(2:l);
% logdiff_pi = diff(log_pi); 
% X = horzcat(logdiff_pi,log_y,int); % 719*3 
 X =  xlsread('updateddata');
 %X = [logdiff_pi,log_y,int]; 
 
[beta12 LR SSR omega residvarmatrix resids] = VAR(X,12,0);
beta12; % the first line are beta on last period of the 3 variables
disp 'Q1 (a) The covariance matrix of residual of the reduced form is '
residvarmatrix
C = chol(residvarmatrix) ; 
S = C' % Cholesky decompo

%% Question 1 Part b Please also see the writeup
% S3 vector
% S1 vector
I3 = eye(3);
shock_i = I3(:,3);
shock_i_effect = S * shock_i
shock_pi = I3(:,1);
shock_pi_effect = S * shock_pi 
%% Question 1 Part c
% without shock 
t = 731;
m=1 ;
V(m,:) = horzcat(X(t,1:3),X((t-1),1:3),X((t-2),1:3),X((t-3),1:3),X((t-4),1:3),X((t-5),1:3),X((t-6),1:3),...
    X((t-7),1:3),X((t-8),1:3),X((t-9),1:3),X((t-10),1:3),X((t-11),1:3),1);

forecast_ns (1,1) =  sum(beta12(:,1).*V');
forecast_ns (1,2) =  sum(beta12(:,2).*V');
forecast_ns (1,3) =  sum(beta12(:,3).*V');

V_expand (1,:) = horzcat( forecast_ns(1,:), V(:,1:(end-4)),1);
for j=1:3
forecast_ns (2,j) = sum(beta12(:,j).*V_expand');

end
 p=49;
for n = 2: p
V_expand (n,:) = horzcat( forecast_ns(n,1:3), V_expand (n-1,1:end-4),1);
for j=1:3
forecast_ns (n+1,j) = sum(beta12(:,j).*V_expand (n,:)');

end
end
% with shock 

W(m,:) = horzcat(X(t,1:3),X((t-1),1:3),X((t-2),1:3),X((t-3),1:3),X((t-4),1:3),X((t-5),1:3),X((t-6),1:3),...
    X((t-7),1:3),X((t-8),1:3),X((t-9),1:3),X((t-10),1:3),X((t-11),1:3),1);

forecast_s (1,:) =  forecast_ns (1,:) + (S*shock_i)';
V_expand_s (1,:) = horzcat( forecast_s(1,:), W(:,1:end-4),1);

for j=1:3
forecast_s (2,j) = sum(beta12(:,j).*V_expand_s');

end
 p=49;
for n = 2: p
 V_expand_s (n,:) = horzcat( forecast_s(n,1:3), V_expand_s (n-1,1:end-4),1);

forecast_s (n+1,1) = sum(beta12(:,1).*V_expand_s(n,:)');
forecast_s (n+1,2) = sum(beta12(:,2).*V_expand_s(n,:)');
forecast_s (n+1,3) =  sum(beta12(:,3).*V_expand_s(n,:)');
end
forecast_s;
forecast_ns;
IRF (:,:)= forecast_s- forecast_ns;

IRF_pi (:,1) = IRF (:,1);
IRF_y (:,2) = IRF (:,2);
IRF_int (:,3) = IRF (:,3);
a = [1:1:50];

figure('Name','Q1(c) 1 SD interest rate shock');

f(1) = subplot (3,1,1);
plot(a, IRF_pi) 

title('IRF for Inflation to SD =1 int rate shock')
ylabel('Inflation') 
f(2) = subplot (3,1,2);
plot(a, IRF_y)
title('IRF for Output to int rate shock')
ylabel('Output') 
f(3) = subplot (3,1,3);
plot(a, IRF_int)
title('IRF for Interest Rate to int rate shock')
xlabel('time') 
ylabel('Interest Rate') 

%% Question 1 Part d
forecast_s (1,:) =  forecast_ns (1,:) + (S*shock_pi)';
V_expand_s (1,:) = horzcat( forecast_s(1,:), W(:,1:end-4),1);

forecast_s (2,1) = sum(beta12(:,1).*V_expand_s(1,:)');
forecast_s (2,2) = sum(beta12(:,2).*V_expand_s(1,:)');
forecast_s (2,3) = sum(beta12(:,3).*V_expand_s(1,:)');
 
 p=49;
for n = 2: p
 V_expand_s (n,:) = horzcat( forecast_s(n,1:3), V_expand_s (n-1,1:end-4),1);

forecast_s (n+1,1) = sum(beta12(:,1).*V_expand_s(n,:)');
forecast_s (n+1,2) = sum(beta12(:,2).*V_expand_s(n,:)');
forecast_s (n+1,3) =  sum(beta12(:,3).*V_expand_s(n,:)');
end
forecast_s;

IRF1 (:,:)= forecast_s- forecast_ns;
IRF_pi1 (:,1) = IRF1 (:,1);
IRF_y1(:,2) = IRF1 (:,2);
IRF_int1 (:,3) = IRF1 (:,3);
a = [1:1:50];

figure('Name','Q1(d) 1 SD inflation shock');

f(1) = subplot (3,1,1);
plot(a, IRF_pi1) 
title('IRF for Inflation to inflation shock')
ylabel('Inflation') 
f(2) = subplot (3,1,2);
plot(a, IRF_y1)
title('IRF for Output to inflation shock')
ylabel('Output') 
f(3) = subplot (3,1,3);
plot(a, IRF_int1)
title('IRF for Interest Rate to inflation shock')
xlabel('time') 
ylabel('Interest Rate') 

%% Question 1 Part e 
% What is the impact effect of a 0.25 percent int rate shock on output and
% inflation under this recursive ordering ?
% Ans: Under this ordering, interest rate variable is the fastest variable,
% so interest rate shock will no impact on inflation and output which is
% slower variable within the same period. 

% What is the impact effect of a 1 percent inflation shock on output and
% interestrate ? 
epsilo1 = 0.01/S(1,1)
Sshock_1pi = S*([epsilo1 0 0]')


%% Question 1 Part f
shock_f = [0 0 0.25 /S(3,3)] %use 0.25 as interest rate data is already in percentage

forecast_s (1,:) =  forecast_ns (1,:) + (S*shock_f')';
V_expand_s (1,:) = horzcat( forecast_s(1,:), W(:,1:end-4),1);

forecast_s (2,1) = sum(beta12(:,1).*V_expand_s(1,:)');
forecast_s (2,2) = sum(beta12(:,2).*V_expand_s(1,:)');
forecast_s (2,3) = sum(beta12(:,3).*V_expand_s(1,:)');
 
 p=49;
for n = 2: p
 V_expand_s (n,:) = horzcat( forecast_s(n,1:3), V_expand_s (n-1,1:end-4),1);

forecast_s (n+1,1) = sum(beta12(:,1).*V_expand_s(n,:)');
forecast_s (n+1,2) = sum(beta12(:,2).*V_expand_s(n,:)');
forecast_s (n+1,3) =  sum(beta12(:,3).*V_expand_s(n,:)');
end
forecast_s;

IRFf (:,:)= forecast_s- forecast_ns;
IRF_pif (:,1) = IRFf (:,1);
IRF_yf(:,2) = IRFf (:,2);
IRF_intf (:,3) = IRFf (:,3);
a = [1:1:50];

figure('Name','Q1(f) 0.25% monetary int rate shock');

f(1) = subplot (3,1,1);
plot(a, IRF_pif) 
title('IRF for Inflation to a 0.25% monetary shock')
ylabel('Inflation') 
f(2) = subplot (3,1,2);
plot(a, IRF_yf)
title('IRF for Output to a 0.25% monetary shock')
ylabel('Output') 
f(3) = subplot (3,1,3);
plot(a, IRF_intf)
title('IRF for Interest Rate to a 0.25% monetary shock')
xlabel('time') 
ylabel('Interest Rate') 
disp 'comparing with (c) the shapes of IRFs are the same, however the magnitude of the'
disp 'fluctuation in (c) is greater. The reason is that both have the same impact effect S matrix '
disp 'and of course same S3, in (f) after rescale the 0.25 change and it is equivalent to' 
disp 'have a strucutual [0 0 0.7403] shock which is smaller than standard deviation [ 0 0 1] shock.'
%% Question 1 Part g
shock_g = [0 0 1/S(3,3)] % use 1 as 1% based on interest rate data is already in percentage

forecast_s (1,:) =  forecast_ns (1,:) + (S*shock_g')';
V_expand_s (1,:) = horzcat( forecast_s(1,:), W(:,1:end-4),1);

forecast_s (2,1) = sum(beta12(:,1).*V_expand_s(1,:)');
forecast_s (2,2) = sum(beta12(:,2).*V_expand_s(1,:)');
forecast_s (2,3) = sum(beta12(:,3).*V_expand_s(1,:)');
 
 p=49;
for n = 2: p
 V_expand_s (n,:) = horzcat( forecast_s(n,1:3), V_expand_s (n-1,1:end-4),1);

forecast_s (n+1,1) = sum(beta12(:,1).*V_expand_s(n,:)');
forecast_s (n+1,2) = sum(beta12(:,2).*V_expand_s(n,:)');
forecast_s (n+1,3) =  sum(beta12(:,3).*V_expand_s(n,:)');
end
forecast_s;

IRFg (:,:)= forecast_s- forecast_ns;
IRF_pig (:,1) = IRFg (:,1);
IRF_yg(:,2) = IRFg (:,2);
IRF_intg (:,3) = IRFg (:,3);
a = [1:1:50];

figure('Name','Q1(g) 1% monetary int rate shock');

f(1) = subplot (3,1,1);
plot(a, IRF_pig) 
title('IRF for Inflation to a 1% monetary shock')
ylabel('Inflation') 
f(2) = subplot (3,1,2);
plot(a, IRF_yg)
title('IRF for Output to a 1% monetary shock')
ylabel('Output') 
f(3) = subplot (3,1,3);
plot(a, IRF_intg)
title('IRF for Interest Rate to a 1% monetary shock')
xlabel('time') 
ylabel('Interest Rate') 
disp 'comparing with (c), the shapes of IRFs are the same, however the magnitude of the'
disp 'fluctuation in (g) is greater.'
disp 'The reason is that both have same impact effect S matrix and of course the same S3,'
disp 'in (g), after rescale the 1 percent change and it is equivalent.'
disp 'to have a strucutual [0 0 2.9614] shock which is greater than standard deviation [ 0 0 1] shock.'
%% Question 1 Part h
% based on inflation data, use 0.01
% disp 'The shock is'
% [epsilo1 0 0]

forecast_s (1,:) =  forecast_ns (1,:) + (Sshock_1pi)';
V_expand_s (1,:) = horzcat( forecast_s(1,:), W(:,1:end-4),1);

forecast_s (2,1) = sum(beta12(:,1).*V_expand_s(1,:)');
forecast_s (2,2) = sum(beta12(:,2).*V_expand_s(1,:)');
forecast_s (2,3) = sum(beta12(:,3).*V_expand_s(1,:)');
 
 p=49;
for n = 2: p
 V_expand_s (n,:) = horzcat( forecast_s(n,1:3), V_expand_s (n-1,1:end-4),1);

forecast_s (n+1,1) = sum(beta12(:,1).*V_expand_s(n,:)');
forecast_s (n+1,2) = sum(beta12(:,2).*V_expand_s(n,:)');
forecast_s (n+1,3) =  sum(beta12(:,3).*V_expand_s(n,:)');
end
forecast_s;

IRFh (:,:)= forecast_s- forecast_ns;



IRF_pih (:,1) = IRFh (:,1);
IRF_yh(:,2) = IRFh (:,2);
IRF_inth (:,3) = IRFh (:,3);
a = [1:1:50];

figure('Name','Q1(h) 1% Inflation shock');

f(1) = subplot (3,1,1);
plot(a, IRF_pih) 
title('IRF for Inflation to a 1% Inflation shock')
ylabel('Inflation') 
f(2) = subplot (3,1,2);
plot(a, IRF_yh)
title('IRF for Output to a 1% Inflation shock')
ylabel('Output') 
f(3) = subplot (3,1,3);
plot(a, IRF_inth)
title('IRF for Interest Rate to a 1% Inflation shock')
xlabel('time') 
ylabel('Interest Rate') 
disp 'comparing with (d) the shape of IRFs are the same, however the magnitude of the'
disp 'IRF fluctuation in (h) is greater. The reason is that both have save impact effect S matrix '
disp 'and of course same S1, in (h) after rescale the 1 percent change and it is equivalent'
disp 'to have a strucutual [6.5621 0 0] shock which is greater than standard deviation [ 1 0 0] shock.'