function [alphag] = drawSTAlphag(stateTransitionsg,...
    stateTransitionsStar, Factor, factorVariance, g0, G0)
[Rows, ~] = size(Factor);
[~, Arp] = size(stateTransitionsg);
zeroarp = zeros(1,Arp);
alphag = zeros(Rows,1);
for i = 1: Rows
    sigma2 = factorVariance(i); 
    stStar = stateTransitionsStar(i,:);
    stg = stateTransitionsg(i,:);
    [y,x] = kowLagStates(Factor(i,:), Arp);
    G = ((G0\eye(Arp)) +  (x*x')./sigma2 )\eye(Arp);
    gammahat = (G* ((G0\g0) +  (x*y')./sigma2))';
    num = logmvnpdf(Factor(i,1), zeroarp, initCovar(stStar,sigma2));
    den = logmvnpdf(Factor(i,1), zeroarp, initCovar(stg, sigma2));
    alphag(i) = min(0, num-den) + logmvnpdf(stStar, gammahat,G);
end
end

