function [p] = drawPhi(yt,ybar, deltas, obsv )
[K,~] = size(yt);
[~,lags] = size(deltas);
deltasPriorMean = zeros(1,lags);
deltasPriorPre = eye(lags);
deltasPriorsM = deltasPriorPre*deltasPriorMean';
ebar = [zeros(K, lags),ybar];
Xbar = lagMat(ebar, lags);
proposalVarianceN = (deltasPriorPre + Xbar*Xbar')\eye(lags);
proposalMeanN = proposalVarianceN*(deltasPriorsM + (Xbar*ybar')./obsv);
c=0;
unitCircle = 2;
while unitCircle >1
    c = c + 1;
    draw = proposalMeanN + chol(proposalVarianceN,'lower')*normrnd(0,1,lags,1);
    Phi = [draw'; eye(lags-1), zeros(lags-1,1)];
    unitCircle = sum(eig(Phi));
    if c == 20
        draw= deltas;
        break
    end
end
proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVarianceN);
Likelihood = @(g)logmvnpdf(g, zeros(1,K), eye(K));
eN = ybar - draw'*Xbar;
sseN = eN*eN';
LikelihoodN = Likelihood(sseN./obsv);
proposalN = proposalDist(deltas);
eD = ybar - deltas*Xbar;
sseD = eD*eD';
LikelihoodD = Likelihood( sseD./obsv);
proposalD = proposalDist(draw');
alpha = min(0,(LikelihoodN + proposalN) - (LikelihoodD + proposalD));
if log(unifrnd(0,1)) < alpha
    p = draw;
else
    p = deltas;
end
end

