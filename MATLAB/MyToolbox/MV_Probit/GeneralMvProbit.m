function [Output] = GeneralMvProbit(yt, X, Sims, bn, estMethod, estml, b0, B0, g0, G0, a0, tau, varargin)
args = nargin - 12;
if args > 1
    initFt = varargin{1};
    InfoCell = varargin{2};
end

if estMethod == 1
    [storeBeta, storeSigma0,ml, overview] = mvp_ChibGreenbergSampler(yt, X, Sims,bn,  estml, b0, B0,  g0, G0, a0, tau);
    Output{1} = storeBeta;
    Output{2} = storeSigma0;
    Output{6} = ml;
    Output{6} = overview;
else
    [storeBeta, storeFt, storeSt, storeOm, ml, overview]  = mvp_WithFactors(yt, X, Sims, bn,...
        InfoCell, b0, B0, g0, G0, a0, tau, initFt, estml);
    Output{1} = storeBeta;
    Output{2} = storeFt;
    Output{3} = storeSt;
    Output{4} = storeOm;
    Output{5} = ml;
    Output{6} = overview;
end
end

