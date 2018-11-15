function [arparams] = kowUpdateArParameters(StateVariables, Arp)

[Rows] = size(StateVariables,1);
arparams = zeros(Rows, Arp);
for i = 1: Rows
    [y,x] = kowLagStates(StateVariables(i,:), Arp);
    arparams(i,:) = (x*x')\x*y' ;
end

end

