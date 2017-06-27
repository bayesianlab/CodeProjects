function [  ] = arkSimulations(J, sims)
muA1 = [0, .5, 1];
muB1 = [-.5, 0, .5];
muC1 = [-1, -.5, 0];
rho = [-.7, -.3, .3, .7];

mus = zeros(1, 3, 3);
mus(1, :, 1) =  muA1;
mus(1, :, 2) =  muB1;
mus(1, :, 3) =  muC1;

bd = 1e6;
lim = 50;

k = J/3;
names = {'A', 'B', 'C'};
fprintf('J = %i\n', J)
for j = 1:3
    muj = kron(ones(1,k), mus(1,:,j));
    fprintf('mu %s\n', names{j})
    for i = 1:length(rho)
        sigmai = createSigma(rho(i), J);
        [marginalLikelihood, se ] = arkSimulator(0,Inf, muj, sigmai, sims, bd, lim);
        fprintf('rho = %.1f (Marginal Likelihood, NSE) = (%.4f, %.4f)\n',...
            rho(i), marginalLikelihood, 100*se)
    end
    fprintf('\n')
end
end