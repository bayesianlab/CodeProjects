function [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, Sigma0, Sims,bn, ...
    b0, B0, tau0, T0, s0, S0)
[K,T]=size(yt);
[~,P]=size(X);
KT =K*T;
KP = K*P;
IKP = eye(KP);
surX = surForm(X,K);
subsetIndices=reshape(1:KT, K,T);
IK = eye(K);
ZeroK = zeros(1,K);

beta = repmat(b0,K,1);
kronB0inv=kron(eye(K), diag(1./diag(B0)));
kronB0invb0=kronB0inv*beta;
zt = yt;

StationaryRuns = Sims-bn;
B = K*(K-1)/2;
storeSigma0 = zeros(B, StationaryRuns);
storeBeta = zeros(KP,StationaryRuns);

unvech = unVechMatrixMaker(K,-1);
vechIndex = vechIndices(K);
mut = reshape(surX*beta,K,T);

for s = 1:Sims
    fprintf('Simulation %i\n', s)
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt,mut,Sigma0);
    % Sample beta
    beta = mvp_betadraw(zt,surX, Sigma0, subsetIndices, kronB0inv, kronB0invb0);
    mut = reshape(surX*beta,K,T);
    demuyt = zt-mut;
    
    % Sample Correlation Mat
    Sigma0 = mvp_rwSigmaDraw(Sigma0,demuyt, tau0, T0, s0, S0, unvech,...
        vechIndex);
    
    % Store Posteriors
    if s > bn
        m = s-bn;
        sigmas = vech(Sigma0, -1);
        storeSigma0(:,m) = sigmas;
        storeBeta(:,m) = beta;
    end
    
end
end

