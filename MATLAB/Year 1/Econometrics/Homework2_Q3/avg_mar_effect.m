function [ marginal_effects, standard_deviation_marginal_effects ] =...
    avg_mar_effect( betas, X )
% betas needs to passed as rows
[r,c] = size(betas);

pi = 1./(1+exp(-X*betas));
prob = pi.*(1-pi);
sum1 = zeros(1,c);
sum2 = zeros(1,c);
sum3 = zeros(1,c);

for i = 1:c
    cur_prob = prob(:,i);
    sum1(1,i) = mean(betas(1,i)*cur_prob);
    sum2(1,i) = mean(betas(2,i)*cur_prob);
    sum3(1,i) = mean(betas(3,i)*cur_prob);
end

ame1 = mean(sum1);
std1 = std(sum1);
ame2 = mean(sum2);
std2= std(sum2);
ame3 = mean(sum3);
std3 = std(sum3);

marginal_effects = [ame1, ame2, ame3]';
standard_deviation_marginal_effects = [std1, std2, std3]';


end

