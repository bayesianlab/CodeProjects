function [Output] = GeneralMvProbit(yt, X, Sims, bn, estMethod, estml, b0, B0, g0, G0, a0, varargin)
args = nargin - 11;
if args > 1
    A0 = varargin{1};
    initFt = varargin{2};
    InfoCell = varargin{3};
end

if estMethod == 1
    [storeBeta, storeSigma0] = mvp_ChibGreenbergSampler(yt, X, Sims,bn,  estml, b0, B0,  g0, G0, a0);
    Output{1} = storeBeta;
    Output{2} = storeSigma0;
else
    [storeBeta, storeFt, storeSt, storeOm, storeD, ml]  = mvp_WithFactors(yt, X, Sims, bn,...
        InfoCell, b0, B0, g0, G0, a0, A0, initFt, estml);
    Output{1} = storeBeta;
    Output{2} = storeFt;
    Output{3} = storeSt;
    Output{4} = storeOm;
    Output{5} = storeD;
    Output{6} = ml;
end
end

