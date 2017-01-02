clear
clc



alphaInit = 1;
alphaEnd = 1.5;
guess = [5, 5]';
p= 1.01;
pEnd = 8;


% halfCirc = newtonWithParameter(@System, @Jacobian, guess, 1, 2.9, 10^(-2), 100, 10^(-2));
% figure(1)
% plot(halfCirc(:, 1), halfCirc(:,2))
% xlabel('\alpha')
% ylabel('X')
% figure(2)
% plot(halfCirc(:, 1), halfCirc(:,3))
% xlabel('\alpha')
% ylabel('Y')
% sols = newtonWithParameter(@G, @JacobianSys, guess, .99, 10, 10^(-2), 100, 10^(-2))
% scatter3(sols(:,1), sols(:,2), sols(:,3))
% sols = newtonArc(@System, @Jacobian, @JacobianAlpha, guess, alphaInit, alphaEnd, 25, 2000, 10^(-2), 10^(-4));
% figure(3)
% plot(sols(:,3), sols(:,1))
% xlabel('\alpha')
% ylabel('X')
% figure(4)
% plot(sols(:,3), sols(:,2))
% xlabel('\alpha')
% ylabel('Y')

[q4, sols] = newtonArc(@G, @JacobianSys, @JacobianP, [.3;1.2], 1.1, 10, 10^(-2),...
     40, 1000, 10^(-5) , 10^(-4));

figure(5)
plot(q4(:,3), q4(:,1))
xlabel('\alpha')
ylabel('X')
figure(6)
plot(q4(:,3),  q4(:,2))
xlabel('\alpha')
ylabel('Y')

figure(7)
plot(sols(:,1), sols(:,2))
xlabel('\alpha')
ylabel('X')
figure(8)
plot(sols(:,1), sols(:,3))
xlabel('\alpha')
ylabel('X')

% figure(1)
% scatter3(q4(:,3), q4(:,1), q4(:,2))
% G(q4(1,1:2), q4(1,3))
% figure(2)
% scatter3(sols(:,1), sols(:,2), sols(:,3))
% title('Regular newton')





