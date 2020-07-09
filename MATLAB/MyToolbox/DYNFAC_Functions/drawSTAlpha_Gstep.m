function [alphag] = drawSTAlphag(stateTransitionsg,...
    stateTransitionsStar, Factor, factorVariance, g0, G0)
[Rows, ~] = size(Factor);
T=size(Factor,2);
[~, lags] = size(stateTransitionsg);
IP = eye(lags);
IT = eye(T);
alphag = zeros(Rows,1);
for r = 1: Rows
    sigma2 = factorVariance(r);
    stStar = stateTransitionsStar(r,:);
    stg = stateTransitionsg(r,:);
    yt = Factor(r,:);
    ytstar = Factor(r,lags+1:end);
    Xt = lagMat(yt,lags)';
    Xp = zeros(lags, lags);
    c=lags;
    for h = 1:lags
        Xp(:,h) = [zeros(c,1); ytstar(1:h-1)'];
        c = lags -h;
    end

    Xss = [Xp;Xt];
    
    Pstar = initCovar(stStar, sigma2);
    Pg =  initCovar(stg, sigma2);
    Sg = full(spdiags(repmat(sigma2,T,1), 0, T, T));
    Sstar = Sg;
    Sstar(1:lags, 1:lags) = Pstar;
    Sstarlower = chol(Sstar,'lower');
    Sg(1:lags, 1:lags) = Pg;
    Sglower = chol(Sg,'lower');
    
    Sstarlowerinv  = chol(Sstar,'lower')\IT;
    Sglowerinv = chol(Sg, 'lower')\IT;
    
    ystar = Sstarlower*( yt' - Xss*stStar');
    yg = Sglower*( yt' - Xss*stg');
        
    G1 = ((G0\IP) +  (Xt'*Xt)./sigma2 )\IP;

    g1= (G1* ((G0\g0') +  (Xt'*ytstar')./sigma2))';

    Num = adjustedlogmvnpdf(ystar', Sstarlowerinv)+logmvnpdf(stStar, g0, G0)+logmvnpdf(stg, g1, G1);
    Den = adjustedlogmvnpdf(yg', Sglowerinv)+logmvnpdf(stg, g0, G0)+logmvnpdf(stStar, g1, G1);

    alphag(r) = min(0, Num-Den) + logmvnpdf(stStar, g1,G1);
end
end

