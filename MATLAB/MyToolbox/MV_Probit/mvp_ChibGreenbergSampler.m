function [storeBeta, storeSigma,ml, summary] = mvp_ChibGreenbergSampler(yt, X, Sims,bn, estml, ...
    b0, B0, s0, S0, Sigma0, tau)
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
ap = zeros(K-1,1);
for s = 1:Sims
    fprintf('Simulation %i\n', s)
    % Sample latent data
    
    zt = mvp_latentDataDraw(zt,yt,mut,Sigma0);
    % Sample beta
    beta = mvp_betadraw(zt,surX, Sigma0, subsetIndices, kronB0inv, kronB0invb0);
    mut = reshape(surX*beta,K,T);
    demuyt = zt-mut;

    % Sample Correlation Mat
%     [Sigma0, accept] = mvp_rwSigmaDraw(Sigma0,demuyt,  s0, S0, unvech,...
%         vechIndex, begIndexOptimize, tau);
%     ap = ap + accept;
    % Store Posteriors
    if s > bn
        m = s-bn;
        sigmas = vech(Sigma0, -1);
        storeSigma(:,m) = sigmas;
        storeBeta(:,m) = beta;
        storeLatent(:,:,m) = zt;
    end

end
accept_probability = ap./Sims
storeLatentj = storeLatent;
ztj = mean(storeLatentj,3);
Sigma0j = Sigma0;
betaStar = mean(storeBeta,2);
mutStar = reshape(surX*betaStar,K,T);
storePibetastar = zeros(1,Runs);
storeSigma0j = zeros(B,Runs);
if estml == 1
for r = 1 : Runs
    fprintf('Reduced run beta %i \n', r)
    Sigma0g = storeSigma(:,r);
    Q = unvech*Sigma0g;
    Q =reshape(Q,K,K);
    Sigma0g = Q + Q' + eye(K);
    ztg = storeLatent(:,:,r);
    storePibetastar(r) = mvp_pibeta(betaStar, ztg,surX, Sigma0g, subsetIndices,...
        kronB0inv, kronB0invb0);

    demuyt = ztj-mutStar;
    Sigma0j = mvp_rwSigmaDraw(Sigma0j,demuyt,  s0, S0, unvech,...
        vechIndex, begIndexOptimize,tau);
    ztj = mvp_latentDataDraw(ztj,yt,mutStar,Sigma0j);
    storeLatentj(:,:,r) = ztj;
    sigmasj = vech(Sigma0j, -1);
    storeSigma0j(:,r) = sigmasj;
        Q = unvech*sigmasj;
    Q =reshape(Q,K,K);
    Sigma0j = Q + Q' + eye(K);
end
betaprior = logmvnpdf(betaStar', beta0',  diag(ones(KP,1).*B0));
piBetaOrdinate = logAvg(storePibetastar);
storeSigma0g = storeSigma0j;

msig = mean(storeSigma0g,2);
SigmaStar = reshape(unvech*msig, K,K) ;
SigmaStar = SigmaStar + SigmaStar' + eye(K);
SigmaStarG = SigmaStar;
star = vech(SigmaStar,-1);
storesks =  std(storeSigma0g,[],2);
storeKsums = zeros(K-1,Runs);

storeSigmagCopy = storeSigma0g;


piSigma = zeros(K-1,1);
sigPriors = zeros(1,K-1);
for k = 1:K-2
    vindx = vechIndex(k,1) : vechIndex(k,2);
    vplus = vechIndex(k+1,1) : vechIndex(k+1,2);
    nsubk = length(vindx);
    bk = storesks(k)*Runs^(-1/(4+nsubk));
    sstar = star(vindx);
    sigPriors(k) = logmvnpdf(sstar', s0.*ones(nsubk,1)', S0.*eye(nsubk));
    fprintf('Block %i\n',k)
    for r = 1 : Runs
        fprintf('\tReduced run %i \n', r)
        sg = storeSigma0g(:,r);
        sgfree = sg(vindx);
        
        kprod = zeros(nsubk,1);
        for j = 1:nsubk
            kprod(j) = logmvnpdf( (sstar(j) - sgfree(j) )./bk,0,1 ) - log(bk);
        end
        storeKsums(k,r) = prod(exp(kprod));
        star(vplus) = sg(vplus);
        t = reshape(unvech*star, K,K);
        CurStar = t + t' + eye(K);
        [~,p]= chol(CurStar);
        if p~=0
            zt = mvp_latentDataDraw(zt,yt,mutStar,SigmaStar);
            storeLatentj(:,:,r) = zt;
            demuyt = zt-mutStar;
            Sigma0g = mvp_rwSigmaDraw(SigmaStar,demuyt,  s0, S0, unvech,...
                vechIndex, k+1,tau);
            s=vech(Sigma0g,-1);
            storeSigmagCopy(vindx,r) = sstar;
            storeSigmagCopy(vplus,r) = s(vplus);
        else
            zt = mvp_latentDataDraw(zt,yt,mutStar,CurStar);
            storeLatentj(:,:,r) = zt;
            demuyt = zt-mutStar;
            Sigma0g = mvp_rwSigmaDraw(CurStar,demuyt,  s0, S0, unvech,...
                vechIndex, k+1, tau);
            s=vech(Sigma0g,-1);
            storeSigmagCopy(vindx,r) = sstar;
            storeSigmagCopy(vplus,r) = s(vplus);
        end
    end
    piSigma(k) = -log(Runs) + log(sum(storeKsums(k,:),2));
    storeSigma0g = storeSigmagCopy;
end
SigmaStar = mean(storeSigma0g,2);
star = SigmaStar(end);
vv = vechIndex(K-1,1):vechIndex(K-1,2);
SigmaStar = reshape(unvech*SigmaStar,K,K);
SigmaStar = SigmaStar + SigmaStar' + eye(K)
[~,m]=chol(SigmaStar);
if m~=0
    SigmaStar = SigmaStarG;
end
bk = storesks(end)*Runs^(-.2);

fprintf('Last block\n')
for r = 1 : Runs
    fprintf('\tReduced run %i \n', r)
    x= storeSigma0g(vv,r);
    storeKsums(K-1, r) = exp(logmvnpdf( (star - x )./bk,0,1 ) - log(bk));
end
sigPriors(end) = logmvnpdf(star, s0(end), S0);
piSigma(end) = -log(Runs) + log(sum(storeKsums(K-1,:),2));
piSigma = sum(piSigma);



fprintf('Computing log likelihood\n')
LogLikelihood = sum(ghk_integrate(yt, mutStar, SigmaStar, 1000));
priors = [betaprior, sum(sigPriors)]
posterior = [piSigma, piBetaOrdinate]
LL = LogLikelihood
ml=LL + sum(priors) - sum(posterior)
summary = table({'LogLikelihood', 'betaprior', 'sigPriors', 'piSigma', 'piBetaOrdinate'}',[LogLikelihood, priors, -posterior]')
else
    ml=0;
    summary=0;
end