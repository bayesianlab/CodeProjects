function [ output_args ] = ghkSimulations( J, sims )
fprintf('GHK simulations\n')
muA1 = [0, .5, 1];
muB1 = [-.5, 0, .5];
muC1 = [-1, -.5, 0];
rho = [-.7, -.3, .3, .7];

mus = zeros(1, 3, 3);
mus(1, :, 1) =  muA1;
mus(1, :, 2) =  muB1;
mus(1, :, 3) =  muC1;

k = J/3;
names = {'A', 'B', 'C'};
fprintf('J = %i\n', J)
for j = 1:3
    muj = kron(ones(1,k), mus(1,:,j));
    fprintf('mu %s\n', names{j})
    for i = 1:length(rho)
        sigmai = createSigma(rho(i), J);
        [marginalLikelihood ] = ghk(1, sims, J, muj, sigmai);
        fprintf('rho = %.1f Marginal Likelihood = %.4f\n', rho(i), marginalLikelihood)
    end
    fprintf('\n')
end

end


