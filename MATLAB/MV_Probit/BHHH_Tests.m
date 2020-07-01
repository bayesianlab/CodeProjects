% Regression Data Test for BHHH
% clear;clc;
% rng(8)
% T = 1000;
% p = 10;
% b = unifrnd(-1,1,1,p)
%
% X = normrnd(0,1,T, p);
% y = (X*b' + normrnd(0,1, T,1)) ;
%
%
%

% Fn = @(one,two,three) -LinRegLL(one,two,three);
% nFn = @(guess) -LinRegLL(guess,y,X);
% FD = @(guess) FiniteDifferencer(guess, nFn, 1);
% g = zeros(1,p)';
opts = optimoptions(@fminunc, 'Display', 'iter', 'FiniteDifferenceType', 'central');
% tic
% [fmp,~,~,~,grad,h] =fminunc(nFn, g, opts)
% toc
% tic
% [x, B] = Bhhh(g, Fn,  y,X, 1e-3, 30,1);
% toc
% tic
% [bfx, bfh] = bfgs(g, eye(p), nFn)
% [~,x]= chol(bfh)
% toc
% [b',fmp,x]
% eqns = 2:100;
eqns = 2:100;
c = 0;
t1 = zeros(length(eqns),1);
t2= zeros(length(eqns),1);

for e  = eqns
    c = c + 1;
    
    [yt, Xt, InfoCell, Factors, gammas, betas, A, factorvar, omvar] = GenerateSimData(e, 1, 100);
    L0 = initCovar(gammas, 1);
    StatePrecision = FactorPrecision(gammas, L0, 1, 100);
    a0m = ones(e-1,1);
    A0invp = eye(e-1);
    [K,T]= size(yt);
    
    top = ones(e-1,1);
    ydemu = yt - reshape(Xt*betas, K,T);
    ty = ydemu(2:end,:);
    
    LL = @(guess) -LLcond_ratio(guess, ty, a0m', A0invp, top, Factors,StatePrecision);
    g= ones(e-1,1);
    tic
    [bfx, bfh] = bfgs(g, A0invp, LL);
    t1(c) = toc;
    tic
    [~,~,~,~,~,hh]= fminunc(LL, g, opts);
    t2(c) = toc;
end
hold on 
plot(t1)
plot(t2)
    % tic
    % [w,~,~,~,~,hh]= fminunc(LL, g, opts);
    % toc
    % [bfx, w]
    
% end
% bfh = bfh + eye(eqns-1).*lambda;
% [~, i] = chol(bfh)