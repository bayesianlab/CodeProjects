function [ArParams] = kowUpdateArParameters(ArParams, StateVariables, Arp)
fprintf('\nUpdating ar parameters on state variables\n')
[Rows, ~] = size(StateVariables);
accept = 0;
zeroarp = zeros(1,Arp);

% X = StateVariables(:,1:end-Arp);
% Y = StateVariables(:,Arp+1:end);
% 
% Prior = eye(Rows).*1e-3;
% 
% (1./diag(X*X')).*diag(X*Y')

for i = 1: Rows
    State = StateVariables(i,:);
    Ar = ArParams(i,:);
    [y,x] = kowLagStates(State, Arp);
    [proposal, P0, P0old] = kowArPropose(y,x, Ar);
    num = logmvnpdf(State(1:Arp), zeroarp, P0);
    den = logmvnpdf(State(1:Arp), zeroarp, P0old);
    alpha = min(0, num-den);
    if log(unifrnd(0,1,1,1)) <= alpha
        accept = accept + 1;
        ArParams(i,:) = proposal;
    end
end
end

