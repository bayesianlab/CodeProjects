function [ll] = newtest(guess,y,x,Omega)
mu = x*guess;
ll = logmvnpdf(y,mu',Omega);
end

