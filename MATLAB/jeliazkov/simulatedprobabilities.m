clear 
clc
rng(101, 'twister');
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
    post1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
    post2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/yi' ...
    yi


Sims = 100;
N = 1000;
X = [x1,x2];
beta = [post1;post2];

% AR Simulator
qi = 2.*y-1;
eps = normrnd(0,1,N,Sims);

fun = @(b)ARmethodSimulateMoments(b);
% options = optimset('Display', 'iter', 'MaxFunEvals', 100, 'TolFun', 1e-4);
% [x,fval] = fminsearch(fun, [0;.1295], options) 
i = 1;
reps = 5;
storage = zeros(2,reps);
b = [0.02;0.1];
storage(:,1) = b;
while i < 5
    [fx, x] = nelderMeadMin(storage(:,i),fun, 100, .05, 1e-6, 1)
    i = i + 1
    storage(:,i) = x;
end
mean(storage,2)


    










