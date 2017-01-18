
format long
clear 
clc
tol = [10^(-7), 10^(-18)];
maxIt = 10^3;
x = linspace(.01,1, 10);
for t =1:length(tol)
     disp(sprintf('\n\tTolerance set to \n\t%.18f', tol(t)))
     for i =1:length(x)
         getTerms(x(i), tol(t), maxIt);
     end
 end
