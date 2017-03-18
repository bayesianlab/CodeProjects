function [ sumDLL ] = probitSimulatedScore(beta,delta )
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/eps' ...
    eps
X = [x1,x2];

centeredP = ARsimulator(X,beta,eps);
indx = find(centeredP == 0 | centeredP == 1);
y(indx) = [];
centeredP(indx) = [];
X(indx,:) = [];
eps(indx,:) = [];
[obs, cols]= size(X);
h =eye(cols).*delta;
derivLL = zeros(obs, cols);
for i = 1:cols
    Dup = ARsimulator(X,beta+h(:,i),eps);
    Ddown = ARsimulator(X,beta-h(:,i),eps);
    derivLL(:,i) = (Dup - Ddown )./(2*delta);
end
P1MPinv = (centeredP.*(1-centeredP)).^(-1);
Q = (derivLL.*P1MPinv);
sumDLL = Q'*(y-centeredP);
% Q =( (P1MPinv .* (y-centeredP))'*derivLL )';
% quadForm = ((y-centeredP).*sum(Q.*Q, 1)')'*(y-centeredP);

end

