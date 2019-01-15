function [soln] = mvnrndPrecision(mu, diagLowerChol, offdiagL)
T = length(diagLowerChol);
eta = normrnd(0,1,T,1);
soln = zeros(T,1);
for i = 1:T
    soln(i) = (eta(i) - offdiagL(i,:)*soln)/diagLowerChol(i);
end
soln = mu +soln;
end

