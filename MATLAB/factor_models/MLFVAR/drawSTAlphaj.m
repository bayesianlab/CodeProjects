function [stateTransitions, alphaj] = drawSTAlphaj(stateTransitions, StateVariables, factorVariance, Arp)
[Rows, ~] = size(StateVariables);
accept = 0;
zeroarp = zeros(1,Arp);
alphaj = zeros(Rows,1);
for i = 1: Rows
    sigma2 = factorVariance(i);
    State = stateTransitions(i,:);
    st = stateTransitions(i,:);
    [y,x] = kowLagStates(State, Arp);
    [stj, P0, P0old] = kowArPropose(y,x, st, sigma2);
    num = logmvnpdf(State(1:Arp), zeroarp, P0);
    den = logmvnpdf(State(1:Arp), zeroarp, P0old);
    alphaj(i) = min(0, num-den);
    if log(unifrnd(0,1,1,1)) <= alphaj(i)
        accept = accept + 1;
        stateTransitions(i,:) = stj;
    end
end
end

