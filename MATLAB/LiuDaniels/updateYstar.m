function [zdraws] = updateYstar(y,mu,Covariance)
[K,T] = size(y);
GHK =0;
if GHK == 1
    L = chol(Covariance, 'lower');
    Linv = chol(Covariance\eye(K), 'lower');
    standevs = diag(L);
    offL = tril(L,-1);
    eta = zeros(K,T);
    for t = 1:T
        yt = y(:,t);
        for k = 1:K
            if 0 < yt(k)
                adjust = offL(k,:)*eta(:,t);
                alpha = -(mu(k) +adjust)/standevs(k);
                eta(k,t) =  truncatedBelow(alpha, 0, 1);
            else
                adjust = offL(k,:)*eta(:,t);
                beta = -(mu(k) +adjust)/standevs(k);
                eta(k,t) =  truncatedAbove(beta, 0, 1);
            end
        end
    end
    zdraws = mu + L*eta;
else
    H = Covariance\eye(K);
    h = sqrt(1./diag(H));
    vterms = zeros(K,K-1);
    notk = 1:K;
    for k = 1:K
        select = notk(notk~= k);
        vterms(k,:) = -H(k,k)\H(k,select);
    end
    zdraws = zeros(K, T);
    Alpha = (zeros(K,1) - mu)./h;
    for t = 1:T
        ztemp = zeros(K,1);
        yt = y(:,t);
        for k = 1:K
            select = notk(notk~=k);
            cmean = vterms(k,:)*ztemp(select);
            if 0 < yt(k)
                ztemp(k) = truncatedBelow(Alpha(k), cmean , h(k));
            else
                ztemp(k) = truncatedAbove(Alpha(k),cmean, h(k));
            end
        end
        zdraws(:,t) = mu(:,t) + ztemp ;
    end
end
end
