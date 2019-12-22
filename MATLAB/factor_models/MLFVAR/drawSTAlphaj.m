function [stateTransitions, alphaj] = drawSTAlphaj(stateTransitions, StateVariables, factorVariance, g0,G0)
[Rows, ~] = size(StateVariables);
[~, Arp] = size(stateTransitions);
accept = 0;
zeroarp = zeros(1,Arp);
alphaj = zeros(Rows,1);
for i = 1: Rows
    notValid =1;
    count =0;
    sigma2 = factorVariance(i);
    st = stateTransitions(i,:);
    [y,x] = kowLagStates(StateVariables(i,:), Arp);
    G = ((G0\ones(Arp)) +  (x*x')./sigma2 )\eye(Arp);
    gammahat = G* ( (G0\g0) +(x*y')./sigma2);
    while notValid == 1 & count < 100
        proposal = (gammahat+chol(G,'lower')*normrnd(0,1,Arp,1))';
        [P0,~,~,notValid]= initCovar(proposal);
        count = count + 1;
    end
    if count == 100 & notValid==1
        P0 = eye(Arp);
    end
    [P0old,~,~,~]=initCovar(st);
    num = logmvnpdf(StateVariables(i,1:Arp), zeroarp, P0);
    den = logmvnpdf(StateVariables(i, 1:Arp), zeroarp, P0old);
    alphaj(i) = min(0, num-den);
    if log(unifrnd(0,1,1,1)) <= alphaj(i)
        accept = accept + 1;
        stateTransitions(i,:) = proposal;
    end
end
end

