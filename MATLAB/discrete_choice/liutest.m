function [ stoR0, ar ] = liutest(a,b, z, R0, D0, Sims,burnin )
K = size(R0,1);
[~, SampleSize] = size(z);
postDraws = 0;
newz = zeros(K,SampleSize);
stoR0 = zeros(K,K, Sims-burnin);
lu = log(unifrnd(0,1,Sims,1));
accept = 0;
eyek = eye(K);
for i = 1:Sims
    fprintf('%i\n',i)
  for t = 1:SampleSize
    newz(:,t) = geweke91(a,b,zeros(K,1),R0,1,0,z(:,t));
  end
    % Correlation Matrix Part
    WishartParameter = D0*(newz*newz')*D0';
    dSi = diag(diag(WishartParameter).^(-.5));
    WishartParameter = dSi*WishartParameter*dSi;
    W = iwishrnd(WishartParameter, SampleSize*K);
    d0 = diag(W).^(.5);
    canD0 = diag(d0);
    canD0i = diag(d0.^(-1));
    canR = canD0i * W * canD0i;
    mhprob = min(0, .5*(K + 1)*(logdet(canR) - logdet(R0)) );
    if lu(i) < mhprob
        accept = accept + 1;
        R0 = canR;
        D0 = canD0;
    end
    if i > burnin
        postDraws = postDraws + 1;
%        R0avg = R0avg + R0;
       stoR0(:,:,postDraws) = R0;
    end
end
ar = accept/Sims;
end


