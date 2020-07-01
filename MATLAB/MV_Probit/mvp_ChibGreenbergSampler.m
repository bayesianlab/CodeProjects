function [storeBeta, storeSigma,ml] = mvp_ChibGreenbergSampler(yt, X, Sims,bn, estml, ...
    b0, B0, s0, S0, Sigma0)
[K,T]=size(yt);
[~,P]=size(X);
KT =K*T;
KP = K*P;
surX = surForm(X,K);
subsetIndices=reshape(1:KT, K,T);


beta0 = ones(KP,1).*b0;
kronB0inv=diag(ones(KP,1)./B0);
kronB0invb0=kronB0inv*beta0;
zt = yt;

Runs = Sims-bn;
B = K*(K-1)/2;
storeSigma = zeros(B, Runs);
storeBeta = zeros(KP,Runs);
storeLatent = zeros(K,T,Runs);
unvech = unVechMatrixMaker(K,-1);
vechIndex = vechIndices(K);

mut = reshape(surX*beta0,K,T);

begIndexOptimize = 1;
for s = 1:Sims
    fprintf('Simulation %i\n', s)
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt,mut,Sigma0);
    % Sample beta
    beta = mvp_betadraw(zt,surX, Sigma0, subsetIndices, kronB0inv, kronB0invb0);
    mut = reshape(surX*beta,K,T);
    demuyt = zt-mut;
    
    % Sample Correlation Mat
    Sigma0 = mvp_rwSigmaDraw(Sigma0,demuyt,  s0, S0, unvech,...
        vechIndex, begIndexOptimize);
    
    % Store Posteriors
    if s > bn
        m = s-bn;
        sigmas = vech(Sigma0, -1);
        storeSigma(:,m) = sigmas;
        storeBeta(:,m) = beta;
    end
    
end

msig = mean(storeSigma,2);
free_elems = reshape(unvech*msig, K,K) ;
SigmaStar = free_elems + free_elems' + eye(K);
star = vech(SigmaStar,-1);
storesks =  std(storeSigma,[],2);
storeKsums = zeros(K-1,Runs);

storeSigmag = storeSigma;
storeSigmagCopy = storeSigmag;
storeBetag = zeros(KP,Runs);

sigPriors = zeros(1,K-1);
for k = 1:K-2
    vindx = vechIndex(k,1) : vechIndex(k,2);
    vplus = vechIndex(k+1,1) : vechIndex(k+1,2);
    nsubk = length(vindx);
    bk = storesks(k)*Runs^(-1/(4+nsubk));
    sstar = star(vindx);
    sigPriors(k) = logmvnpdf(sstar', s0(vindx)', S0.*eye(nsubk));
    for r = 1 : Runs
        fprintf('Reduced run %i block %i \n', r,k)
        sg = storeSigmag(:,r);
        sgfree = sg(vindx);
        kprod = zeros(nsubk,1);
        for j = 1:nsubk
            kprod(j) = logmvnpdf( (sstar(j) - sgfree(j) )./bk,0,1 ) - log(bk);
        end
        storeKsums(k,r) = sum(kprod);
        star(vplus) = sg(vplus);
        t = reshape(unvech*star, K,K);
        CurStar = t + t' + eye(K);
        storeLatent(:,:,r) = mvp_latentDataDraw(zt,yt,mut,CurStar);
        storeBetag(:,r) = mvp_betadraw(zt,surX, CurStar, subsetIndices, kronB0inv, kronB0invb0);
        Sigma0 = mvp_rwSigmaDraw(CurStar,demuyt,  s0, S0, unvech,...
            vechIndex, k+1);
        s=vech(Sigma0,-1);
        storeSigmagCopy(vindx,r) = sstar;
        storeSigmagCopy(vplus,r) = s(vplus);
    end
    storeSigmag = storeSigmagCopy;
end
SigmaStar = mean(storeSigmag,2);
vv = vechIndex(K-1,1):vechIndex(K-1,2);
star = mean(storeSigmagCopy(vv,:),2);
SigmaStar(end) = star;
SigmaStar = reshape(unvech*SigmaStar,K,K);
SigmaStar = SigmaStar + SigmaStar' + eye(K);
bk = storesks(end)*Runs^(-.2);
for r = 1 : Runs
    fprintf('Reduced run %i last block \n', r)
    x= storeSigmagCopy(vv,:);
    storeKsums(K-1, r) = logmvnpdf( (star - x )./bk,0,1 ) - log(bk);
end
sigPriors(end) = logmvnpdf(star, s0(end), S0);
piSigmaStar = sum(logAvg(storeKsums));

betaStar = mean(storeBeta,2);
storePibetastar = zeros(1,Runs);
for r = 1 : Runs
    fprintf('Reduced run beta %i \n', r)
    zt = mvp_latentDataDraw(zt,yt,mut,SigmaStar);
    storePibetastar(r) = mvp_pibeta(betaStar, zt,surX, SigmaStar, subsetIndices, kronB0inv, kronB0invb0);
end
betaprior = logmvnpdf(betaStar', beta0',  diag(ones(KP,1).*B0));
piBetaStar = logAvg(storePibetastar);

Xbeta = reshape(surX*betaStar,K,T);
fprintf('Computing log likelihood\n')
LogLikelihood = sum(ghk_integrate(yt, Xbeta, SigmaStar, 1000));
priors = [betaprior, sum(sigPriors)]
posterior = [piSigmaStar, piBetaStar]
LL = LogLikelihood
ml=LL + sum(priors) - sum(posterior)
end