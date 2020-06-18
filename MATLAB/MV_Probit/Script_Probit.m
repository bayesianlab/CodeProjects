clear;clc;
cg = 1;
rng ( 11) 
if cg == 1
    T = 10;
    K=10;
    Q = 3;
    X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
    beta = ones(Q,K);
    surX = surForm(X, K);
    R = createSigma(.5,K);
    epsilon = mvnrnd(zeros(1,K), R, T)';
    zt=reshape(surX*beta(:) + epsilon(:), K,T);
    yt = double(zt > 0);
    
    mean(zt,2)
    
    b0= zeros(Q,1);
    B0 =100.*eye(Q);
    Sims=1000;
    bn = 10;
    tau0 = 0;
    T0 = .5;
    s0 = vech(R, -1);
    S0 = .5;
    R0 = eye(K);
    
    estml =1 ;
    [Output]=GeneralMvProbit(yt, X,Sims, bn, cg, estml, b0, B0,  s0, S0, R0);
    storeBeta = Output{1};
    storeSigma = Output{2};
    msig = mean(storeSigma,2);
    unvech = unVechMatrixMaker(K,-1);
    reshape(unvech*msig, K,K) + reshape(unvech*msig, K,K)' + eye(K)
    
else
    T = 100;
    K=20;
    Q = 3;
    X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
    A = ones(K,1);
    A(2:end,1) = (K-1:-1:1)'./10;
    C = A*A' + diag(ones(K,1));
    D = diag(C).^(-.5);
    Astar = diag(D)*A;
    gamma = .5;
    P0= initCovar(gamma, 1);
    FP = FactorPrecision(gamma,P0, 1, T)\eye(T) ;
    Ft = mvnrnd(zeros(1,T), FP,1);
    beta = ones(Q,1);    
    zt = reshape(X*beta,K,T) + Astar*Ft + normrnd(0,1/sqrt(2),K,T);
    yt = double(zt > 0);
    
    lags = 1;
    R0 = ones(K,1);
    g0 = zeros(1,lags);
    G0=diag(fliplr(.5.^(0:lags-1)));
    b0= ones(Q,1);
    B0 =100.*eye(Q);
    a0 = 1;
    A0= 1;
    s0 = 6;
    S0 = 6;
    v0 = 6;
    r0 = 6;
    Sims=100;
    bn = 10;
    InfoCell = {[1,K]};
    
    [Output] =GeneralMvProbit(yt, X, Sims, bn, cg, b0, B0, g0, G0, a0, A0,...
        Ft, InfoCell);
    
    storeBeta = Output{1};
    storeFt= Output{2};
    storeSt= Output{3};
    storeOm = Output{4};
    storeD = Output{5};
    mubeta = round(mean(storeBeta,2),3);
    table(mubeta,repmat(beta(:), K,1) )
    
    meanst = round(mean( squeeze(storeSt)),3);
    table( meanst, gamma)
    
    ombar = round(mean(storeOm,3),3);
    table(ombar, Astar)
   
    Fhat = mean(storeFt,3);
    hold on
    plot(Ft)
    plot(Fhat)
end