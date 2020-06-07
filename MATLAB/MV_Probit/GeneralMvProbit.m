function [Output] = GeneralMvProbit(yt, X, Sigma0, Sims, bn, estMethod, varargin)
b0 = varargin{1};
B0 = varargin{2};
s0 = varargin{3};
S0 = varargin{4};
v0 = varargin{5};
r0 = varargin{6};
g0 = varargin{7};
G0 = varargin{8} ;
a0 = varargin{9};
A0 = varargin{10};
InfoCell = varargin{11};
if estMethod == 1
    [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, Sigma0, Sims,bn,  b0, B0,  s0, S0);
    Output{1} = storeBeta;
    Output{2} = storeSigma0;
else
    [storeBeta, storeFt, storeSt, storeFv, storeOv, storeOm, storeD]  = mvp_WithFactors(yt, X, Sigma0, Sims, bn, InfoCell,...
        b0, B0,s0, S0, v0, r0, g0, G0, a0, A0);
    Output{1} = storeBeta;
    Output{2} = storeFt;
    Output{3} = storeSt;
    Output{4} = storeFv;
    Output{5} = storeOv;
    Output{6} = storeOm;
    Output{7} = storeD;
end
end

