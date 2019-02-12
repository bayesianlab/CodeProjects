function [obsEqnVariances,residuals2] = kowUpdateObsVariances(residuals, v0, r0, T )
fprintf('Updating obs. eqn variance\n')
residuals2 = sum(residuals.^2,2);
obsEqnVariances = 1./gamrnd((T + v0)./2, 2./(residuals2+r0));
end

