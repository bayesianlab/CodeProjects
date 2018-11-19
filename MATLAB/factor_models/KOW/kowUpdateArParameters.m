function [arparams] = kowUpdateArParameters(ArParams, StateVariables, Arp)

[Rows, T] = size(StateVariables);
arparams = zeros(Rows, Arp);
T = T- Arp;
for i = 1: Rows
    State = StateVariables(i,:);
    Ar = ArParams(i,:);
    Ar2 = Ar.*Ar;
    [y,x] = kowLagStates(State, Arp);
    G = eye(size(x,1)) +  x*x';

    gammahat = linSysSolve(chol(G,'lower'), x*y');
    proposal = mvnrnd(gammahat, G);
    proposal2 = proposal.*proposal;
    v = 1/(proposal2(1) - proposal2(2) - proposal2(3));
    vold = 1/(Ar2(1) - Ar2(
    while v < 1e-3  
        proposal = mvnrnd(gammahat, G);
        proposal2 = proposal.*proposal;
        v = 1/(proposal2(1) - proposal2(2) - proposal2(3));
    end
    
    log(normpdf(State(1), 0, v)) - log(normpdf(State(1), 0, ArParams))
    

end

end

