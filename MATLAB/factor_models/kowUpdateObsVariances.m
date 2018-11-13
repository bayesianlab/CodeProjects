function [obsEqnVariances] = kowUpdateObsVariances(residuals, v0, r0, T )
residuals2 = sum(residuals.^2,2);
obsEqnVariances = 1./gamrnd((T + v0)./2, (residuals2+r0)./2);
end

