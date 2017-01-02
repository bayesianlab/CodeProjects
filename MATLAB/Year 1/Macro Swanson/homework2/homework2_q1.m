%% Question 1
clear
clc
format 

[loutput, ldinflation, irate] = createData();
data = [ldinflation, loutput, irate];
[row_dat, col_dat] = size(data);
[coeffs, resids, covar] = vreg(data, 12);
% coeffs
covar
% % Part a
S_Q1 = chol(covar,'lower')
% S*S'
epsilon = eye(3,3)
S_1 = S_Q1(:,1);
S_2 = S_Q1(:,2);
S_3 = S_Q1(:,3);
e_pi = epsilon(1,:);
e_y = epsilon(2,:);
e_i = (.25/S_3(3))*epsilon(3,:);

% Impact Effects

% % Part c
monetary_shock = (S_Q1*e_i')'

str1 = sprintf('Q1 c');
xlabels = {'Log Difference Inflation', 'Log Output', 'Interest Rate'};
% IRF_var(50, data, 12, monetary_shock, str1,xlabels );

% % Part d
e_pi = (.01/S_1(1))*epsilon(1,:);
impact = S_Q1*e_pi'
inflation_shock = (S_Q1*e_pi')'
str2 = sprintf('Q1 d');
% IRF_var(50, data, 12, inflation_shock, str2, xlabels);

%% Question 2
% % Part a
different_ordering = [loutput, ldinflation, irate];
[coeffs_2, resids_2, covar_2] = vreg(different_ordering, 12);
covar_2
S_Q2 = chol(covar_2, 'lower')

% Part b
e_iq2 = ((.25/S_Q2(3,3))*epsilon(3,:))';
monetary_shock_q2 = (S_Q2*e_iq2)'
str3 = sprintf('Q2 c');
xlabels = { 'Log Output', 'Log Difference Inflation', 'Interest Rate'};
% IRF_var(50, different_ordering, 12, monetary_shock_q2, str3, xlabels);

e_piq2 = ((.01/S_Q2(2,2)) * epsilon(2,:))';
inflation_shock_q2 = (S_Q2*e_piq2)'
impact = S_Q2 * e_piq2
str4 = sprintf('Q2 d');
% IRF_var(50, different_ordering, 12, inflation_shock_q2, str4, xlabels);

[ldoutput, ldinflation, irate] = createData2();
block_data = [ldoutput, ldinflation, irate];
[coefs_q3, resids_q3, covar_q3] = vreg(block_data, 12);
S_Q3 = chol(covar_q3, 'lower');
e_i = (.25/S_3(3))*epsilon(3,:);
monetary_shock_q3 = (S_Q1*e_i')'
str5 = sprintf('Q3 a');
xlabels = { 'Log Difference Output', 'Log Difference Inflation',...
    'Interest Rate'};
% IRFlevel_var(50, block_data, 12, monetary_shock, str5, xlabels);




