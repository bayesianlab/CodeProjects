clear
clc


g1 = [
    .3, 0, 0, 0, 0, 0, 0;
    0, .3, 0, 0, 0, 0, 0;
    0, 0, .8, 0, 0, 0, 0;
    0, 0, 0, .95, 0, 0, 0;
    0, 0, 0, 0, .5, 0, 0;
    0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 1;
    ];

psi = [
    0, 0, 0;
    0, 0, 0;
    0, 0, .3;
    .5, 0, 0;
    0, .3, 0;
    0, 0, 0;
    0, 0, 0;
];

pi = [
    0, 0;
    0, 0;
    0, 0;
    0, 0;
    0, 0;
    1, 0;
    0, 1
];

periods = 40;
alpha = [0.1, 0.25, 0.5, 0.75, 0.95];
n = length(alpha);
F = zeros(7,7, n);
G = zeros(7,3,n);
yt_response_mp = zeros(7,periods, length(alpha));
legendinfo = {};
figure(1)
for i = 1:length(alpha)
    kappa = ((1-alpha(i)) * (1- (.99*alpha(i))) / alpha(i)) * (3.5);
    g0 = [
        1, 0, .6667, .04286, 0, -.67, -.6667;
        -kappa, 1, 0, 0, -1, 0, -.67;
        -.025, -.3, 1, 0, 0, 0, 0;
        0, 0, 0, 1, 0, 0, 0;
        0, 0, 0, 0, 1, 0, 0;
        1, 0, 0, 0, 0, 0, 0;
        0, 1, 0, 0, 0, 0, 0;
        ];
    
    % gensys solution
    [F(1:7, 1:7, i) ,~,G(1:7, 1:3, i),~,~,~,~,eu,~] = ...
        gensys(g0,g1,0, psi, pi);
    eu
    % impulse response
    yt_response_mp(:,:, i) = impulse_mp(F(1:7, 1:7, i),...
        G(1:7, 1:3, i), periods, .10);
    
    % plot 
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    hold(ax1, 'on')
    hold(ax2, 'on')
    plot(ax1, 1:periods, yt_response_mp(1,:,i))
    plot(ax2, 1:periods, yt_response_mp(2,:,i))
    legendinfoX{i} = sprintf('x_t response \\alpha = %.2f', alpha(i));
    legendinfoP{i} = sprintf('\\pi_t response \\alpha = %.2f', alpha(i));
end
title(ax1, 'Monetary Policy Shock on X_t')
title(ax2, sprintf('Monetary Policy Shock on \\pi_t'))
legend(ax1, legendinfoX)
legend(ax2, legendinfoP)

figure(2)
F_tech = zeros(7,7, n);
G_tech = zeros(7,3,n);
yt_response_tech = zeros(7,periods, length(alpha));
for i = 1:length(alpha)
    kappa = ((1-alpha(i)) * (1- (.99*alpha(i))) / alpha(i)) * (3.5);
    g0 = [
        1, 0, .6667, .04286, 0, -.6667, -.6667;
        -kappa, 1, 0, 0, -1, 0, -.6667;
        -.025, -.3, 1, 0, 0, 0, 0;
        0, 0, 0, 1, 0, 0, 0;
        0, 0, 0, 0, 1, 0, 0;
        1, 0, 0, 0, 0, 0, 0;
        0, 1, 0, 0, 0, 0, 0;
        ];

    % gensys solution
    [F_tech(1:7, 1:7, i) ,~,G_tech(1:7, 1:3, i),~,~,~,~,eu,~] = ...
        gensys(g0,g1,0, psi, pi);
    
    % Impulse response
    yt_response_tech(:,:,i) = impulse_tech(F_tech(1:7, 1:7, i),...
        G_tech(1:7, 1:3, i), periods, .10);
    
    % Plot
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    hold(ax1, 'on')
    hold(ax2, 'on')
    plot(ax1, 1:periods, yt_response_tech(1,:,i))
    plot(ax2, 1:periods, yt_response_tech(2,:,i))
    legendinfoX{i} = sprintf('x_t response \\alpha = %.2f', alpha(i));
    legendinfoP{i} = sprintf('\\pi_t response \\alpha = %.2f', alpha(i));
    
end
title(ax1, 'Technology Shock on X_t')
title(ax2, sprintf('Technology Shock on \\pi_t'))
legend(ax1, legendinfoX)
legend(ax2, legendinfoP)


