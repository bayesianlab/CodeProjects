function [ArParams] = kowUpdateArParameters(ArParams, StateVariables, Arp)
fprintf('\nUpdating ar parameters on state variables\n')
[Rows, T] = size(StateVariables);
for i = 1: Rows
    State = StateVariables(i,:);
    Ar = ArParams(i,:);
    Ar2 = Ar.*Ar;
    [y,x] = kowLagStates(State, Arp);
    G = eye(size(x,1)) +  x*x';
    gammahat = linSysSolve(chol(G,'lower'), x*y');
    proposal = mvnrnd(gammahat, G);
    proposal2 = proposal.*proposal;
    v = 1/(1 - sum(proposal2));
    vold = 1/(1-sum(Ar2));
    while v < 1e-3  
        proposal = mvnrnd(gammahat, G);
        proposal2 = proposal.*proposal;
        v = 1/(proposal2(1) - proposal2(2) - proposal2(3));
    end
    alpha = min(0, log(normpdf(State(1), 0, v)) -...
        log(normpdf(State(1), 0, vold)));
    if log(unifrnd(0,1,1,1)) < alpha
        ArParams(i,:) = proposal;
    end
    

end

end

