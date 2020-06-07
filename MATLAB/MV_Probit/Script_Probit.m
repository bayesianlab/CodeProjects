clear;clc;
cg = 0;

if cg == 1
    T = 100;
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
    bn = 100;
    tau0 = 0;
    T0 = .5;
    
    s0 = vech(R, -1);
    S0 = .5;
    R0 = eye(K);
    
    % [storeBeta, storeSigma0]=GeneralMvProbit(yt, X, R0, b0, B0, tau0, T0, s0, S0, Sims, bn,...
    %     cg);
    
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
    P0= initCovar(.5, 1);
    FP = FactorPrecision(.5,P0, 1, T) ;
    Ft = mvnrnd(zeros(1,T), FP,1);
    beta = ones(Q,1);
    
    yt = reshape(X*beta,K,T) + Astar*Ft + normrnd(0,1,K,T);
    zt = yt;
    lags = 1;
    R0 = ones(K,1);
    g0 = zeros(1,lags);
    G0=diag(fliplr(.5.^(0:lags-1)));
    b0= zeros(Q,1);
    B0 =100.*eye(Q);
    a0 = 1;
    A0= 1;
    s0 = 6;
    S0 = 6;
    v0 = 6;
    r0 = 6;
    Sims=10;
    bn = 1;
    InfoCell = {[1,K]};
    [Output] =GeneralMvProbit(yt, X, R0, Sims, bn, cg, b0, B0, s0, S0,...
        v0, r0, g0, G0, a0, A0, InfoCell);
    
    storeBeta = Output{1};
    storeFt= Output{2};
    storeSt= Output{3};
    storeFv= Output{4};
    storeOv= Output{5};
    storeOm = Output{6};
    storeD = Output{7};
    mubeta = round(mean(storeBeta,2),3);
        table(mubeta,repmat(beta(:), K,1) )
    
    
    ombar = mean(storeOm,3);
    table(ombar, Astar)

    
    Fhat = mean(storeFt,3);
    hold on
    plot(Ft)
    plot(Fhat)
end