function [ss] = stateSpaceIt(params)
% Give params as row vec
lags = size(params,2) ;
zb = zeros(lags-1, 1);
ss = [params;eye(lags-1),zb];
end

