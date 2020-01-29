function [obsEqnVariances,parama, paramb] = kowUpdateObsVariances(residuals, v0, r0, T )
% fprintf('Updating obs. eqn variance\n')
parama= .5*(T + v0);
paramb = .5.*(sum(residuals.^2,2) +r0);
obsEqnVariances = 1./gamrnd( parama, 1./(paramb));
end

