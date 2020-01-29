function [stateTransition] = drawStateTransitions(stateTransition, yt, sigma2, g0, G0)
lags = size(stateTransition,2);
Xt = lagMat(yt,lags)';
eP = eye(lags);
G1 = ((G0\eP) + (Xt'*Xt)/sigma2)\eP;
g1 = G1*( (G0\g0) + (Xt'*yt(lags+1:end)')/sigma2);
notvalid=1;
Glower = chol(G1,'lower');
P0 = initCovar(stateTransition, sigma2);
c=0;
while notvalid == 1
    c = c + 1;
    proposal = g1 + Glower*normrnd(0,1,lags,1);
    [P1,~,~,notvalid] = initCovar(proposal, sigma2);
    if notvalid == 0
        break
    end
    if c == 10
        d = 0;
        while notvalid == 1
            d = d+ 1;
            proposal = stateTransition + mvnrnd(zeros(1,lags), eye(lags));
            [P1,~,~,notvalid] = initCovar(proposal, sigma2);
            if notvalid == 0
                break
            end
            if d == 10
                break
            end
        end
        break
    end
end

alpha = min(0, logmvnpdf(yt(1:lags), zeros(1,lags), P1) - logmvnpdf(yt(1:lags), zeros(1,lags),P0));
if log(unifrnd(0,1)) < alpha
    stateTransition=proposal;
end
end

