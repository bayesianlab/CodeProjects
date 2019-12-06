% Regression Data Test for BHHH
rng(9)
clear;clc;
p = 6;
T = 100;
h= .0000001;
b = [1.5, -3, .1, 0, 2, .9] ;
X = normrnd(0,1,T, p);
y = X*b' + normrnd(0,1, T,1) ;

LinRegLL(b', y, X, 1)
Fn = @(guess, dep, ind) LinRegLL(guess,dep,ind,1);
nFn = @(guess) -LinRegLL(guess,y,X,1);
point = unifrnd(0,1,p,1);

fminunc(nFn, point)
Bhhh(point, Fn,  y,X,h, .01)