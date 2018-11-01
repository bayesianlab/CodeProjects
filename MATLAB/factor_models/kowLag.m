function [X] = kowLag(states, lag)
[Nfactors, T] = size(states);
X = zeros(Nfactors*lag, T-lag);
t = 1:3;
for n = 1:Nfactors
   select = t + (n-1)*lag;
   [~, X(select, :)] = kowLagStates(states(n,:),lag );
end

end

