% Simulate multivariate probit
clear
clc
rng(15)
N = 500;
mu = [.5;.5];

corr = .5;
sigma = [1, corr;corr, 1];

eps = mvnrnd([0;0], sigma, N);
muVec = repmat(mu, 1,N)';
z = muVec + eps;
ylims = -4:.1:4;
xlims = -4:.1:4;
zB = z(z(:,1) > 0 & z(:,2) > 0, :);
sigmaHat = corrcoef(zB);
% figure(1)
% hold on 
% plot(zeros(length(ylims),1), ylims, 'Color', 'black')
% plot(xlims, zeros(length(ylims),1), 'Color', 'black')
% scatter(z(:,1), z(:,2),20, 'blue')
% for i = [.5, .85, .95]
%     ci = ellipse([mu(1);mu(2)], sigma, i, 2);
%     plot(ci(1,:), ci(2,:), 'Color', 'red', 'LineWidth', 2)
% end
% 
% figure(2)
% hold on 
% scatter(zB(:,1), zB(:,2), 'blue')
% xlim([-4,4])
% ylim([-3 4])
% plot(zeros(length(ylims),1), ylims, 'Color', 'black')
% plot(xlims, zeros(length(ylims),1), 'Color', 'black')
% for i = [.4, .65, .9]
%     ci = ellipse([mu(1); mu(2)], sigmaHat, i, 2);
%     plot(ci(1,:), ci(2,:), 'Color', 'red', 'LineWidth', 2)
% end



