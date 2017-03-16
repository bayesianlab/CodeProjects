function [ LL ] = ARmethodSimulateMoments(beta,eps)
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
X = [x1,x2];
simP = ARsimulator(X,beta,eps);
indx = find(simP == 0 | simP == 1);
y(indx) = [];
simP(indx) = [];
LL = -sum(y .* log(simP) + (1-y) .* log(1-simP));
end

