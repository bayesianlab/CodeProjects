clear
clc

% Practice function true solution to y' = 2ty y(1) = 1
f = @(x) exp(x.^2 -1);
tSpan = 1.05:.05:2;
% plot(tSpan, f(tSpan))
true = [tSpan', f(tSpan)'];

% Solution to practice function with implicit method 1
h = .0002;
maxIterations = 10;
eps = 10^-3;
% y1 = 1;
% rk4 = getInitialPoints(20, 1, 1, @practiceFnq, h);
% sol = implicitMethod1([1,2], y1, @practiceFnq, @dPracticeFnq, h,...
%     maxIterations, eps);
% abs(true - sol)
% abs(true - rk4)
% plot(sol(:,1), sol(:,2))
% plot(true(:,1), true(:,2))

y(1,1) = 52.29;
y(2,1) = 83.82;
% s = implicitMethod1([0,2], y, @givenFnq, @jacobianGiven, h,...
%     maxIterations, eps);
% hold on
% plot(s(:,1), s(:,2))
% hold on
% plot(s(:,1), s(:,3))
% [t, y] = ode45(@givenFnq, [0,2], y);
% plot(t, y(:,1))
% 
% [constants, e] = solveHWsystem();
% 
% y1 = @(t,constants, eigenvalues) constants(1,1) * exp(eigenvalues(1,1)*t) + ...
%     constants(1,2) * exp(eigenvalues(2,2)*t);
% y2 = @(t,constants, eigenvalues) constants(2,1) * exp(eigenvalues(1,1)*t) + ...
%     constants(2,2) * exp(eigenvalues(2,2)*t);
% t = linspace(0,2);
% plot(t, y1(t, constants, e))
% plot(t, y2(t, constants, e))
% 
% py = 1
% getInitialPoints(5, 1, py, @practiceFnq, h)
% predictorCorrector([1,2], py, @practiceFnq, @dPracticeFnq, h, eps, maxIterations)

h = .00002;
maxIterations = 10;
eps = 10^-3;
y(1,1) = 52.29;
y(2,1) = 83.82;
sn = predictorCorrector([0,.4], y, @givenFnq, @jacobianGiven, h, eps,...
    maxIterations);

plot(sn(:,1), sn(:,2))





