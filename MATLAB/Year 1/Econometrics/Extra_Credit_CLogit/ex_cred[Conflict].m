clear;
clc;
% 5 characteristics, 5 on choice 
 betas = [ 2.5;-.45];
N = 1000;

choices = 100;

alternative_specific = normrnd(0,50, 2, choices, N);

Y = choice_data(betas, alternative_specific, choices, N);

bs = zeros(length(betas),1);
condlogit(bs, Y, alternative_specific, .99)
condlogit(bs, Y , alternative_specific)
% options = optimset('Display', 'off');
% options.LargeScale = 'off';
% fminunc(@(c)condlogit(c, Y, alternative_specific), bs, options)
% fminunc(@(c)condlogit(c, Y, alternative_specific, .99), bs, options)

% sims = 1000;
% stoBetas = zeros(2, sims);
% for i = 1:sims
%     stoBetas(:,i) = fminunc(@(c)condlogit(c, Y, alternative_specific, .25),...
%         bs, options);
% end
