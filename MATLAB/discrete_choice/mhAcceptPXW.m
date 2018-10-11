function [ alpha ] = mhAcceptPXW(Wstar, Dstar, Rstar, W0, D0,...
    R0, S, nu, Supdate, nuupdate, ...
    latentData, meanLatentData )

K = size(Rstar,1);
JacNum = .5*(K-1)*sum(log(diag(Dstar)));
JacDen = .5*(K-1)*sum(log(diag(D0)));

% surLL computes by row for every column!

% a= logInvWish(Wstar,S,nu)
% b=logInvWish(W0,S,nu)
% c=  logInvWish(W0, Supdate, nuupdate)
% d=logInvWish(Wstar, Supdate, nuupdate)

Num = logInvWish(Wstar,S,nu)+JacNum +...
      surLL(latentData, meanLatentData, Rstar) + ...
      logInvWish(W0, Supdate, nuupdate) ;
Den = logInvWish(W0,S,nu) + JacDen+...
      surLL(latentData, meanLatentData, R0) + ...
      logInvWish(Wstar, Supdate, nuupdate); 
% Num - Den
alpha = min(0, Num - Den);

end

