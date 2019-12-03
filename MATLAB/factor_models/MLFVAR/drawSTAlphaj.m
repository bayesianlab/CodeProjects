function [stateTransitions, alphaj] = drawSTAlphaj(stateTransitions, StateVariables, factorVariance, Arp)
[Rows, ~] = size(StateVariables);
accept = 0;
zeroarp = zeros(1,Arp);
alphaj = zeros(Rows,1);
for i = 1: Rows
    notValid =1;
    count =0;
    sigma2 = factorVariance(i);
    StateAR = stateTransitions(i,:);
    st = stateTransitions(i,:);
    [y,x] = kowLagStates(StateVariables(i,:), Arp);
    G = ((eye(Arp).*.1) +  (x*x')./sigma2 )\eye(Arp);
    gammahat = G* ((x*y')./sigma2);
    while notValid == 1 & count < 20
        proposal = (gammahat+chol(G,'lower')*normrnd(0,1,Arp,1))';
        [P0,~,~,notValid]= initCovar(proposal);
        count = count + 1;
    end
    [P0old,~,~,~]=initCovar(st);
    num = logmvnpdf(StateVariables(1:Arp), zeroarp, P0);
    den = logmvnpdf(StateVariables(1:Arp), zeroarp, P0old);
    alphaj(i) = min(0, num-den);
    if log(unifrnd(0,1,1,1)) <= alphaj(i)
        accept = accept + 1;
        stateTransitions(i,:) = proposal;
    end
end
end

