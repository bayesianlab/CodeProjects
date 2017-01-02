% This script uses fminunc to minimize the negative log likelihood function
% of normally distributed data. Imports data from a file, and uses
% 'Neg LL Norm.m' as function to minimize.
%% Import the data
% When you import data, you can tell MATLAB to generate a script with the
% code to do the same. Below is that code.
X = normrnd(1.33, 2.344, 10000, 1);
% Clear temporary variables
clearvars raw;
%% Options and Implementation
% omptimoptions sets the options for the minimization.
% 'GradObj', 'on', tells fminunc to look at the second output
% argument for the value of the gradient.
options = optimoptions('fminunc','GradObj','on');
% set a starting point
theta_O = [0;1]; % using a semi-colon makes a 2 by 1 column vector
% using a comma makes a 1 by 2 row vector
% defines an 'anonymous' function. Useful for passing other arguments
% to the function. In this case, X is needed to evaluate the LL
f = @(theta)Neg_LL_Norm(theta,X);
% Implementation
[x,fval,exitflag,output,grad,hessian] = fminunc(f,theta_O,options)
% no semi-colon means this line and it's output will print in the Command Window