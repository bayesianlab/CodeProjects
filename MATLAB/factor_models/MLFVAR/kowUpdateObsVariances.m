function [obsEqnVariances,paramb] = kowUpdateObsVariances(residuals, v0, r0, T )
% fprintf('Updating obs. eqn variance\n')
paramb = .5.*(sum(residuals.^2,2) +r0);
% moment1 = (paramb)./(.5*(T + v0) - 1);
% moment2 = ((paramb).^2)./ ((.5*(T + v0) - 1)^2*(.5*(T + v0) - 2));
% [moment1, moment2]
obsEqnVariances = 1./gamrnd( .5*(T + v0), 1./(paramb));
end

