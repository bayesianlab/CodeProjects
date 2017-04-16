
clear; clc;
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/yi' ...
    yi
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
    post1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
    post2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/eps' ...
    eps
rng(101, 'twister')
X = [x1,x2];
beta = [post1;post2];
N = 1000;
Sims = 1000;
qi = 2.*y-1;


delta = .00001;
tol = 1e-3;

gp = @(b)probitLL(y,X, b);
hp = @(b)probitJ(y,X,b);
ll = @(b)probitL(y,X, b);
t = @(b)test(b,ll,gp);

b = [1; 1];

pSS = @(b)probitSimulatedScore(b,delta);
f = @(x)fake(x);
fh = @(x)fakeH(x);


% broydensMethod(pSS, b, eye(2)*.00001, 1e-4, 1e-7, .5, 20, 20)





