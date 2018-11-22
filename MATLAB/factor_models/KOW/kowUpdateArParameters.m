function [ArParams] = kowUpdateArParameters(ArParams, StateVariables, Arp)
fprintf('\nUpdating ar parameters on state variables\n')
[Rows, ~] = size(StateVariables);
accept = 0;
for i = 1: Rows
    State = StateVariables(i,:);
    Ar = ArParams(i,:);
    [y,x] = kowLagStates(State, Arp);
    G = (eye(size(x,1)) +  x*x')\eye(Arp);
    gammahat = G*x*y';
    [proposal, P0] = kowArPropose(gammahat, G);
    num = logmvnpdf(proposal', gammahat', P0);
    den = logmvnpdf(Ar, gammahat', P0);
    alpha = min(0, num-den);
    if log(unifrnd(0,1,1,1)) < alpha
        accept = accept + 1;
        ArParams(i,:) = proposal;
    end
   
end
 fprintf('Accepted %.3f \n', accept/Rows)
end

