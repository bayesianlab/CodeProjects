clear
clc

guess = [1;2];

% Find roots
% a = -4:1:4;
% b = -4:1:4;
% g = [datasample(a,10); datasample(b,10)]';
% [r,c] = size(g);
% fr = 0;
% if fr == 1
%     fprintf('\t SYSTEM 1\n')
%     for i = 1:r
%         newton(g(i,:)', @system1, @jacobian2, 10^-4, 100,0, guess)
%     end
%     fprintf('\t SYSTEM 2\n')
%     for i = 1:r
%         newton(g(i,:)', @system2, @jacobian2, 10^-4, 100,0, guess);
%     end
% end

% Analytic root system 1 are y = -.5 +- sqrt(93)/2 
yRoot1  = -.5 + sqrt(93)/2;
xRoot1 = sqrt(25 - yRoot1^2);
r = [xRoot1;yRoot1];
fprintf('SYSTEM 1\n')
[roots1, constant1] = newton([xRoot1 + 100;yRoot1 + 100], @system1,...
    @jacobian1, 10^-15, 25,0, r);
figure(1)
plot(1:length(constant1), constant1)
title('Quadratic Convergence')
ylabel('Error from root')
xlabel('Iterations')
% Analytic roots system 2 are [0,0], [-1,1]
yRoot21 = 0;
yRoot22 = 1;
xRoot21 = 0;
xRoot22 = -1;

sol1 = [xRoot21; yRoot21];
sol2 = [xRoot22; yRoot22];
fprintf('SYSTEM 2\n')
[roots2, constant2] = newton([-1-.5;1-.5], @system2,...
    @jacobian2, 10^-8, 25, 0, sol2);
figure(2)
plot(constant2)
title('Quadratic Convergence')
ylabel('Error from root')
xlabel('Iterations')
[roots3, constant3] = newton([0+50.5;0+50.5], @system2,...
    @jacobian2, 10^-8, 25, 0, sol2);
figure(3)
plot(constant3)
title('Quadratic Convergence Solution 2 [0,0]')
ylabel('Error from root')
xlabel('Iterations')

% Plot systems 
ps = 0;
if ps == 1
    x = -20:1:15;
    y = -20:1:15;
    [a,b] = meshgrid(x,y);
    [c,d] = meshgrid(x,y);
    figure(4)
    s1 = surf(a, b, eq1(a,b))
    hold on
    s2 = surf(c,d, eq2(c,d))

    figure(5)
    surf(a,b,eq3(a,b))
    hold on
    surf(a,b, eq4( a,b))
end