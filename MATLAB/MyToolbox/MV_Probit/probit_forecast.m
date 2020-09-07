function [yts] = probit_forecast(yt , Xt, storeBeta)
[K,T] = size(yt);
h = size(Xt,1);
S = size(storeBeta,2);
Tout = h/K;
yts = zeros(K,Tout,S);
select = 1:K;
SurX = surForm(Xt,K);
for t = 1:Tout
    rows = select + K*(t-1);
    for s = 1:S
        b = storeBeta(:,s);
        yts(:,t,s) = reshape(SurX(rows,:)*b(:), K,1) +  normrnd(0,1,K,1);

    end
   
end

end