
clear;clc;
s = createSigma(.6,2);
m = .5;
N = 150*4;
x1 = ellipse(m, s, .5, 2);
x2 = ellipse(m, s, .7, 2);
x3 = ellipse(m,s,.9,2);
z2 = ghkGibbsSampler(0, Inf, [m,m], s, floor(N/4))
figure(1)
hold on
xlabel('z1')
ylabel('z2')
plot(x1(1,:), x1(2,:), 'LineWidth', 2, 'Color', 'r')
plot(x2(1,:), x2(2,:),'LineWidth', 2, 'Color', 'r')
plot(x3(1,:), x3(2,:),'LineWidth', 2, 'Color', 'r')
z = mvnrnd([m,m],s, N)
scatter(z(:,1), z(:,2), 'b')
axis([-3,4, -3,4])

figure(2)
hold on 
plot(x1(1,:), x1(2,:), 'LineWidth', 2, 'Color', 'r')
plot(x2(1,:), x2(2,:),'LineWidth', 2, 'Color', 'r')
plot(x3(1,:), x3(2,:),'LineWidth', 2, 'Color', 'r')
xlabel('z1')
ylabel('z2')
scatter(z2(:,1), z2(:,2), 'b')
line([0,0], [0,4], 'LineStyle', '--', 'Color', 'k')
line([0,4], [0,0], 'LineStyle', '--', 'Color', 'k')
axis([-3,4, -3,4])