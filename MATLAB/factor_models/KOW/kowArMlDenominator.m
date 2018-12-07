function [ alphaStartoj ] = kowArMlDenominator( ThetaStar,StateVariables )

[Rows, ~] = size(StateVariables);
alphaStartoj = zeros(Rows,1);
for i = 1:Rows
    State = StateVariables(i,:);
    ArStar = ThetaStar(i,:);
    [y,x] = kowLagStates(State, Arp);
    % den has star
    [~, P0, P0Star, ~, ~] = kowArPropose(y,x, ArStar);
    num = logmvnpdf(State(1:Arp), zeroarp, P0);
    den = logmvnpdf(State(1:Arp), zeroarp, P0Star);
    alphaStartoj(i) = min(0, num-den);
end



end

