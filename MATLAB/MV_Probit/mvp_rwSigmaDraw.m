function [Sigma0] = mvp_rwSigmaDraw(Sigma0, zt, tau0, T0)
[K,~]=size(Sigma0);
lambda=min(eig(Sigma0));
ZeroK = zeros(1,K);

for k = 1:K-1
    CanSig0=Sigma0;
    Rselect= k+1:K;
    sig0 =  Sigma0(Rselect,k);
    lenUnrestricted=length(Rselect);
    ZeroUR = zeros(1,lenUnrestricted);
    h = T0*lambda;
    priorV = diag(h.*ones(1,lenUnrestricted));
    priorVlower = chol(priorV,'lower');
    rw = tau0 +  priorVlower*normrnd(0,1, lenUnrestricted,1);
    proposal= sig0 + rw;
    CanSig0(Rselect,k) = proposal;
    [~,pd]=chol(CanSig0);
    if pd == 0
        N = logmvnpdf(zt', ZeroK, CanSig0)*logmvnpdf(sig0', ZeroUR, priorV);
        D = logmvnpdf(zt', ZeroK, Sigma0)*logmvnpdf(proposal', ZeroUR, priorV);
        alpha = min(0, N-D);
        logu = log(unifrnd(0,1));
        if logu <= alpha
            Sigma0(Rselect,k) = proposal;
            Sigma0(k, Rselect) = proposal;
        end
    end
end
end

