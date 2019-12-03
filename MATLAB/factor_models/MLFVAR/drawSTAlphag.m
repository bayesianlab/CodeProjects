function [alphag] = drawSTAlphag(stateTransitionsg,...
    stateTransitionsStar, Factor, factorVariance, Arp)
[Rows, ~] = size(Factor);
zeroarp = zeros(1,Arp);
alphag = zeros(Rows,1);
for i = 1: Rows
    sigma2 = factorVariance(i); 
    stStar = stateTransitionsStar(i,:);
    stg = stateTransitionsg(i,:);
    [y,x] = kowLagStates(Factor(i,:), Arp);
    G = ((eye(Arp)) +  (x*x')./sigma2 )\eye(Arp);
    gammahat = (G* ((x*y')./sigma2))';
    num = logmvnpdf(Factor(i,1), zeroarp, initCovar(stStar));
    den = logmvnpdf(Factor(i,1), zeroarp, initCovar(stg));
    alphag(i) = min(0, num-den) + logmvnpdf(stStar, gammahat,G);
end
end

