function [storeBeta, storeSigma2, ml] = RestrictedLR_Gibbs(Constraints, y,X,...
    b0, B0, ig_parama0, ig_paramb0, Sims, burnin, samplerType, mltype)
%% LRGibbs
% X is  expected to have T rows and K columns
% mltype: 1 Chibs
% 2 CRT
%
[T, K] = size(X);
IK = eye(K);
B0inv = B0\eye(K);
ig_parama = T + ig_parama0;
XpX = X'*X;
Xpy = X'*y;
sigma2 = 1;
df = 5;
storeBeta = zeros(K, Sims);
storeSigma2 = zeros(1,Sims);
askUpdates = floor(Sims/4);
c=-1;
rz = zeros(K,1);
reta = zeros(K,1);
w = ones(K,1).*.5;
peta = .5;
eta = 0;
if unifrnd(0,1) <= peta
    eta = 1;
end
fprintf('Sampler: ') 
if samplerType == 1
    fprintf('Gibbs MV Normal Sampling\n')
elseif samplerType == 2
    fprintf('ARK MV Normal Sampling\n')
elseif samplerType == 3
    fprintf('MVT Sampling\n')
elseif samplerType == 4
    fprintf('Gibbs MVT Sampling\n')
elseif samplerType == 5
    fprintf('ARKT Sampling\n')
elseif samplerType == 6
    fprintf('ASKT Sampling\n')
end
fprintf('ML Type: ')
for sim = 1:Sims
    % Update beta parameters (mean, variance)
    B1 = ( (XpX/sigma2) + B0inv )\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    if samplerType == 1
        % Normal Sampling
        b1update=GibbsTMVN(Constraints, b1, B1, 1,0);
        storeBeta(:, sim) = b1update;
        
    elseif samplerType == 2
        % Normal Sampling Ark
        b1update=arkSampler(Constraints, b1, B1);
        storeBeta(:, sim) = b1update;
        
    elseif samplerType == 3
        if eta == 1
            
            % Normal Sampling Ask
            b1update= askEta(b1, B1, Constraints);
            b1update = b1+chol(B1,'lower')*b1update';
        else
            b1update = GibbsTMVN(Constraints, b1, B1, 1, 0);
        end
        storeBeta(:,sim) = b1update;
        if mod(sim, askUpdates) == 0
            c = c+1;
            indices = askUpdates*c + (1:askUpdates);
            lagindices= indices(1):indices(end-1);
            indices = indices(2):indices(end);
            A= corr([storeBeta(:,indices)',storeBeta(:,lagindices)']);
            if eta == 1
                reta = diag(A,-K);
                if sum(reta < rz) == K
                    peta = 1;
                elseif sum(reta > rz) == K
                    peta =0;
                else
                    peta = (w'*rz)/(w'*reta + w'*rz);
                end
            else
                rz = diag(A,-K);
                if sum(reta < rz) == K
                    peta = 1;
                elseif sum(reta > rz) == K
                    peta =0;
                else
                    peta = (w'*rz)/(w'*reta + w'*rz);
                end
            end
            if unifrnd(0,1) <= peta
                fprintf('Sample from eta\n')
                eta = 1;
            else
                fprintf('Sample from z\n')
                eta = 0;
            end
        end
    elseif samplerType == 4
        % T sampling Gibbs
        
        b1update = GibbsTMVT(Constraints, b1, B1, df, 1,0);
        storeBeta(:, sim) = b1update;
    elseif samplerType == 5
        % T sampling Ark
        
        b1update=arkTSampler(Constraints, b1, B1, df);
        storeBeta(:, sim) = b1update;
    elseif samplerType == 6
        if eta == 1
            % T Sampling Ask
            
            [b1update,w]= askEtaT(b1, B1, df, Constraints);
            b1update = b1+ (w.*chol(B1,'lower')*b1update');
        else
            b1update = GibbsTMVT(Constraints, b1, B1, df, 1, 0);
        end
        storeBeta(:,sim) = b1update;
        if mod(sim, askUpdates) == 0
            c = c+1;
            indices = askUpdates*c + (1:askUpdates);
            lagindices= indices(1):indices(end-1);
            indices = indices(2):indices(end);
            A= corr([storeBeta(:,indices)',storeBeta(:,lagindices)']);
            if eta == 1
                reta = diag(A,-K);
                if sum(reta < rz) == K
                    peta = 1;
                elseif sum(reta > rz) == K
                    peta =0;
                else
                    peta = (w'*rz)/(w'*reta + w'*rz);
                end
            else
                rz = diag(A,-K);
                if sum(reta < rz) == K
                    peta = 1;
                elseif sum(reta > rz) == K
                    peta =0;
                else
                    peta = (w'*rz)/(w'*reta + w'*rz);
                end
            end
            if unifrnd(0,1) <= peta
                fprintf('Sample from eta\n')
                eta = 1;
            else
                fprintf('Sample from z\n')
                eta = 0;
            end
        end
    end
    % Update sigma2
    e = y - X*b1update;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigma2 = 1/gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
    storeSigma2(:, sim) = sigma2;
end
storeBeta = storeBeta(:,burnin+1:Sims);
storeSigma2 = storeSigma2(:,burnin+1:Sims);
ReducedRuns = Sims-burnin;
%% ML Chibs method
if mltype == 1 && samplerType < 4
    fprintf('Chibs Method Normal Prior\n')
    piBetaStar = zeros(K,ReducedRuns);
    betaj = storeBeta;
    betag = betaj;
    sigma2j = storeSigma2;
    for k = 1 : K
        betaStar = mean(betaj,2);
        betag(1:k,:) = ones(length(1:k), ReducedRuns).*betaStar(1:k);
        betag(k+1:K,:) = betaj(k+1:K,:);
        sigma2g = sigma2j;
        
        for r = 1 : ReducedRuns
            sigma2 = sigma2g(r);
            xtemp = betag(:,r);
            Precision = (XpX/sigma2) + B0inv;
            B1 = ( Precision )\IK;
            b1 = B1 * ( (Xpy/sigma2) + B0inv*b0 );
            if k < K
                piBetaStar(k,r) = conditionaltmvnpdf0(xtemp, b1, B1, Constraints, k);
                betaj = shortGibbsMVN(xtemp, b1, B1, Constraints, k+1);
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            else
                xtemp = betaStar;
                piBetaStar(k,r) = conditionaltmvnpdf0(xtemp, b1, B1, Constraints, k);
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            end
        end
    end
    
    piBetaStar = logAvg(sum(piBetaStar));
    
    e = y-X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigmaStar = mean(sigma2j);
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = tmvnpdf(betaStar', b0', B0, Constraints) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    ml = like + priors - (piSigStar + piBetaStar);
elseif (mltype == 1) && (samplerType >= 4)
    fprintf('Chibs Method T Prior\n')
    piBetaStar = zeros(K,ReducedRuns);
    betaj = storeBeta;
    betag = betaj;
    sigma2j = storeSigma2;
    for k = 1 : K
        betaStar = mean(betaj,2);
        betag(1:k,:) = ones(length(1:k), ReducedRuns).*betaStar(1:k);
        betag(k+1:K,:) = betaj(k+1:K,:);
        sigma2g = sigma2j;
        for r = 1 : ReducedRuns
            sigma2 = sigma2g(r);
            xtemp = betag(:,r);
            Precision = (XpX/sigma2) + B0inv;
            B1 = ( Precision )\IK;
            b1 = B1 * ( (Xpy/sigma2) + B0inv*b0 );
            if k < K
                [cmean,cvar,df12]=tconditionalmoments(xtemp', b1', B1, df, k);
                z = (xtemp(k)-cmean)/sqrt(cvar);
                alpha = -Constraints(k)*cmean;
                if (Constraints(k) == 1) || (Constraints(k) == -1)
                    piBetaStar(k,r) = logtpdf(z, 0, 1, df12) - log( sqrt(cvar)*(1- tcdf( alpha, df12 )) );
                elseif Constraints == 0
                    piBetaStar(k,r) = logtpdf(z, 0, 1, df12);
                else
                    error('Constraints must be 0, 1, or -1.')
                end
                
                betaj = shortGibbsTMVT(xtemp, b1, B1, df, Constraints, k+1);
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            else
                xtemp = betaStar;
                [cmean,cvar,df12]=tconditionalmoments(xtemp', b1', B1, df, k);
                z = (xtemp(k)-cmean)/sqrt(cvar);
                alpha = Constraints(k)*cmean;
                if (Constraints(k) == 1) || (Constraints(k) == -1)
                    piBetaStar(k,r) = logtpdf(z, 0, 1, df12) - log( sqrt(cvar)*(1- tcdf( alpha, df12 )) );
                elseif Constraints == 0
                    piBetaStar(k,r) = logtpdf(z, 0, 1, df12);
                else
                    error('Constraints must be 0, 1, or -1.')
                end
                % Update sigma2
                e = y - X*xtemp;
                ig_paramb = (ig_paramb0 + (e'*e));
                sigma2j(r) = 1 / gamrnd(.5*ig_parama, 1/(.5*ig_paramb));
            end
        end
    end
    piBetaStar = logAvg(sum(piBetaStar));
    e = y-X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    sigmaStar = mean(sigma2j);
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = logtmvtpdf(betaStar', b0', B0, df, Constraints) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    ml = like + priors - (piSigStar + piBetaStar);
    
elseif mltype == 2 && (samplerType < 4)
    fprintf('CRT Method Normal Kernel\n')
    betaStar = mean(storeBeta,2);
    x = zeros(K,1);
    sigmaStar = mean(storeSigma2);
    Kernel = zeros(K, ReducedRuns);
    for k = 1:K-1
        x(1:k) = betaStar(1:k);
        for r = 1 : ReducedRuns
            x(k+1:end) = storeBeta(k+1:end, r);
            Precision = ( (XpX/sigma2) + B0inv );
            B1 = Precision\IK;
            b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
            Kernel(k,r) = conditionaltmvnpdf0(x, b1, B1, Constraints, k);
        end
    end
    x = betaStar;
    Precision = ( (XpX/sigma2) + B0inv );
    B1 = Precision\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    e = y-X*betaStar;
    ig_paramb = (ig_paramb0 + (e'*e));
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    
    Kernel(K,:) = conditionaltmvnpdf0(x, b1, B1, Constraints, K);
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = tmvnpdf(betaStar', b0', B0, Constraints) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    piBetaStar = logAvg(sum(Kernel,1));
    ml = like + priors - (piSigStar + piBetaStar);
    
elseif mltype == 2 && (samplerType >= 4)
    fprintf('CRT Method, Truncated Student T Kernel\n')
    betaStar = mean(storeBeta,2);
    x = zeros(K,1);
    sigmaStar = mean(storeSigma2);
    Kernel = zeros(K, ReducedRuns);
    for k = 1:K-1
        x(1:k) = betaStar(1:k);
        for r = 1 : ReducedRuns
            x(k+1:end) = storeBeta(k+1:end, r);
            Precision = ( (XpX/sigma2) + B0inv );
            B1 = Precision\IK;
            b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
            [cmean,cvar,df12]=tconditionalmoments(x', b1', B1, df, k);
            z = (x(k)-cmean)/sqrt(cvar);
            alpha = -Constraints(k)*cmean;
            if (Constraints(k) == 1) || (Constraints(k) == -1)
                Kernel(k,r) = logtpdf(z, 0, 1, df12) - log( sqrt(cvar)*(1- tcdf( alpha, df12 )) );
            elseif Constraints == 0
                Kernel(k,r) = logtpdf(z, 0, 1, df12);
            else
                error('Constraints must be 0, 1, or -1.')
            end
        end
    end
    
    x = betaStar;
    Precision = ( (XpX/sigma2) + B0inv );
    B1 = Precision\IK;
    b1 = B1 * (  (Xpy/sigma2) + B0inv*b0);
    e = y-X*betaStar;
    [cmean,cvar,df12]=tconditionalmoments(x', b1', B1, df, K);
    z = (x(K)-cmean)/sqrt(cvar);
    alpha = -Constraints(K)*cmean;
    if (Constraints(K) == 1) || (Constraints(K) == -1)
        Kernel(K,:) = logtpdf(z, 0, 1, df12) - log( sqrt(cvar)*(1- tcdf( alpha, df12 )) );
    elseif Constraints == 0
        Kernel(K,:) = logtpdf(z, 0, 1, df12);
    else
        error('Constraints must be 0, 1, or -1.')
    end
    ig_paramb = (ig_paramb0 + (e'*e));
    piSigStar = logigampdf(sigmaStar, .5*ig_parama, (.5*ig_paramb));
    like = logmvnpdf(e'./sigmaStar, zeros(1,T), eye(T));
    priors = tmvnpdf(betaStar', b0', B0, Constraints) + logigampdf(sigmaStar, .5*ig_parama0, (.5*ig_paramb0));
    piBetaStar = logAvg(sum(Kernel,1));
    ml = like + priors - (piSigStar + piBetaStar);
    
elseif mltype==3 && (samplerType < 4)
    fprintf('Importance Sampling, GHKMVN \n')
    XpX = (X'*X);
    XpXinv = (XpX)\eye(K);
    Xpy = X'*y;
    bMLE = XpX\Xpy;
    
    e = y - X*bMLE;
    sSqd = (e'*e)/T;
    thetaMLE = [mean(storeSigma2); mean(storeBeta,2)];
    invFisher = [(2*sSqd^2)/T, zeros(1,K);zeros(K,1), sSqd*XpXinv];
    Constraints = [1, Constraints];
    draws = ghk_simulate(Constraints, thetaMLE, invFisher, ReducedRuns);
    htheta = zeros(1,ReducedRuns);
    like = zeros(1, ReducedRuns);
    priors = zeros(1,ReducedRuns);
    for r = 1:ReducedRuns
        sigma2 = draws(1,r);
        betag = draws(2:end,r);
        e = y-X*betag;
        like(r) = logmvnpdf(e'./sqrt(sigma2), zeros(1,T), eye(T));
        priors(r) = tmvnpdf(betag', b0', B0, Constraints) + logigampdf(sigma2, .5*ig_parama0, (.5*ig_paramb0));
        htheta(r) = tmvnpdf(draws(:,r)', thetaMLE', invFisher, Constraints);
    end
    Importance = like + priors - htheta;
    ml = mean(Importance);
elseif (mltype ==3) && (samplerType >= 4)
    fprintf('Importance Sampling, GHKMVT\n')
    XpX = (X'*X);
    XpXinv = (XpX)\eye(K);
    Xpy = X'*y;
    bMLE = XpX\Xpy;
    e = y - X*bMLE;
    sSqd = (e'*e)/T;
    thetaMLE = [mean(storeSigma2); mean(storeBeta,2)];
    invFisher = [(2*sSqd^2)/T, zeros(1,K);zeros(K,1), sSqd*XpXinv];
    Constraints = [1, Constraints];
    draws = ghkt(thetaMLE, invFisher, df, Constraints, ReducedRuns);
    htheta = zeros(1,ReducedRuns);
    like = zeros(1, ReducedRuns);
    priors = zeros(1,ReducedRuns);
    for r = 1:ReducedRuns
        sigma2 = draws(1,r);
        betag = draws(2:end,r);
        e = y-X*betag;
        like(r) = logmvnpdf(e'./sqrt(sigma2), zeros(1,T), eye(T));

        priors(r) = logtmvtpdf(betag', b0', B0, df, Constraints) + logigampdf(sigma2, .5*ig_parama0, (.5*ig_paramb0));
        htheta(r) = logtmvtpdf(draws(:,r)', thetaMLE', invFisher, df, Constraints);
    end
    Importance = like + priors - htheta;
    ml = mean(Importance);
end


