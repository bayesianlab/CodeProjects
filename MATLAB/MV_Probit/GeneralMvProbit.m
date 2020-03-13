function [storeSigma0, storeBeta] = GeneralMvProbit(yt, X, Sigma0, Sims,bn, b0, B0, tau0, T0)
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
zt = zeros(K,T);

StationaryRuns = Sims-bn;
storeSigma0 = zeros(K,K,StationaryRuns);
storeBeta = zeros(KP,StationaryRuns);


mut = reshape(surX*beta,K,T);

for s = 1:Sims
    fprintf('Simulation %i\n', s)
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt,mut,Sigma0);
    mean(zt,2)'
    
    % Sample beta
    beta = mvp_betadraw(zt,surX, Sigma0, subsetIndices, kronB0inv, kronB0invb0);
    mut = reshape(surX*beta,K,T);
    demuyt = zt-mut;
    
    % Sample Correlation Mat
    %     Sigma0 = mvp_rwSigmaDraw(Sigma0,demuyt, tau0, T0);
    
    % Store Posteriors
    if s > bn
        m = s-bn;
        storeSigma0(:,:,m) = Sigma0;
        storeBeta(:,m) = beta;
    end
    
    
end


end

