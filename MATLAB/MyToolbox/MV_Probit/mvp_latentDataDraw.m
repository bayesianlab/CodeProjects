function [zt] = mvp_latentDataDraw(zt, yt, mut, Sigma0)
[K,T]=size(zt);
Precision=Sigma0\eye(K);
Pkkinv=diag(Precision).^(-1);
selectMat = logical(ones(K)-eye(K));
Pknotk = zeros(K,K-1);
for k = 1:K
    Pknotk(k,:) = Precision(k, selectMat(k,:));
end
for t = 1:T
    ytt = yt(:,t);
    mutt = mut(:,t);
    for k = 1:K
        condmean = mutt(k) - Pkkinv(k)*Pknotk(k,:)*(zt(selectMat(k,:),t) - mutt(selectMat(k,:)));
        if ytt(k) > 0
            zt(k,t) = NormalTruncatedPositive(condmean,Pkkinv(k), 1);
        else
            zt(k,t) = -NormalTruncatedPositive(-condmean,Pkkinv(k), 1);
        end
    end
end
end

