function [Output] = GeneralMvProbit(yt, X, Sims, bn, estMethod, varargin)
args = nargin - 5;
b0 = varargin{1};

B0 = varargin{2};
g0 = varargin{3};
G0 = varargin{4} ;
a0 = varargin{5};
if args > 6
    A0 = varargin{6};
    initFt = varargin{7};
    InfoCell = varargin{8};
end

if estMethod == 1
    [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, a0, Sims,bn,  b0, B0,  g0, G0);
    Output{1} = storeBeta;
    Output{2} = storeSigma0;
else
    [storeBeta, storeFt, storeSt, storeOm, storeD, ml]  = mvp_WithFactors(yt, X, Sims, bn,...
        InfoCell, b0, B0, g0, G0, a0, A0, initFt);
    Output{1} = storeBeta;
    Output{2} = storeFt;
    Output{3} = storeSt;
    Output{4} = storeOm;
    Output{5} = storeD;
    Output{6} = ml;
end
end

