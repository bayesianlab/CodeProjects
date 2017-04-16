% ARK Method
clear 
clc
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
    post1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
    post2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/yi' ...
    yi
beta = [post1; post2];
X = [x1, x2];
pd = makedist('Normal');
tn = truncate(pd, 0, inf);
ark = arkMethod(X, beta, 1000)
[ark,yi]


