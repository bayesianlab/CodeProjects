function [storeBeta, storeSigma0] = GeneralMvProbit(yt, X, Sigma0, b0, B0, tau0, T0, s0, S0,...
    Sims,bn, estMethod)

if estMethod == 1
    [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, Sigma0, b0, B0, tau0, T0, s0, S0,...
        Sims,bn);
else
    [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, Sigma0, b0, B0, tau0, T0, s0, S0,...
        Sims,bn);
end

end

