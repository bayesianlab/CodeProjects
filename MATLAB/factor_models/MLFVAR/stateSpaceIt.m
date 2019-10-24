function [ss] = stateSpaceIt(params,lags)
% Give params as row vec

zb = zeros(lags, size(params,2) - lags + 1)
eye(lags-1)
ss = [params;eye(lags-1),zb];
end

