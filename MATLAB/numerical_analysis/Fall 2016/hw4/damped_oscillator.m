clear 
clc
a = 0;
b = 2*pi;
sims = 2:8;
figures = 1:length(sims)* 3
pcount = 0;
error = zeros(length(sims),1);
particularError = zeros(length(sims),1);
iterCount = 0;
for i = sims
    pcount = pcount + 1;
    iterCount = iterCount + 1
    N = 2^(2*i);
    dx = (b-a) / N;
    t = (a + dx * (0:(N-1)))';
    k =  2*pi/(b-a)*[0:N/2-1, 0, -N/2+1:-1]';

    % Calculate the true function value for fft
    y = 1 - cos(t - .75 * sin(t));
    fourier = fft(y');
    length_fft = length(fourier);
    j = (1:length_fft)';
    d = (1i*k);
    c = (d ).^2 + (.5*d ) + 1;
    yt = ifft(fourier' ./ c);

    %  Derivatives using fft for smooth derivatives and Particular solution
    dyt = ifft(fft(yt) .* k*1i);
    ddyt = ifft( (-k.^2) .*fft(yt));
    yp = ddyt + .5*dyt + yt;

    % Homogeneous solution
    A = yt(1);
    B = (2/(sqrt(15))) * ((.25*A) - dyt(1));
    yh = exp(-.25 *t) .* (A * cos(sqrt(3.75)* t) + B * sin( sqrt(3.75) * t ));

    % General solution
    yg = yh + yp;

    % Matlabs solution to the differential equation
    [T, Y] = ode45(@vp1, t, [0;0]);
    y1 = Y(1:length(T),1);
    dy1 = Y(1:length(T),2);
    ddy1 = diff(dy1)/dx;
    
    len_ddy1 = 1:length(ddy1);
    % General solution for Matlab
    x =  yh(len_ddy1) + ddy1 + .5 *dy1(len_ddy1) + y1(len_ddy1);
    x2 = ddy1 + .5 *dy1(len_ddy1) + y1(len_ddy1);


    % Maximum Error
    error(iterCount) = max(abs(x2(1:length(ddy1))-yp(1:length(ddy1))));
    particularError(iterCount) = max( abs(y - yp))
    % Plots of my soloution and Matlabs solution show that they agree
    figure(figures(pcount))
    hold on
    plot(T(1:length(ddy1)),yg(1:length(ddy1)))
    plot(T(1:length(ddy1)), x(1:length(ddy1)))
    title(sprintf('N = 2^{%i}', 2*i))
    ylabel('y')
    xlabel('t \in [0, 2\pi]')
    hold off
    
    % Particular solution check
    xaxis = t(1:length(ddyt));
    figure(figures(pcount+1))
    hold on
    plot(xaxis, real(yt), 'DisplayName', 'yt')
    plot(xaxis, real(dyt),'DisplayName', 'dyt')
    plot(xaxis, real(ddyt),'DisplayName', 'ddyt')
    plot(xaxis, real(yp),'DisplayName', 'Particular Solution') 
    legend('show')
    title(sprintf('N = 2^{%i}', 2*i))
    hold off

    figure(figures(pcount+2))
    
    subplot(2,1,1)
    plot(xaxis, y(1:length(ddyt)), 'red', 'DisplayName', 'True Function')
    legend('show')
    xlabel('t\in[0,2\pi]')
    ylabel('f(t)')
    title(sprintf('N = 2^{%i}', 2*i))
    
    subplot(2,1,2)
    plot(xaxis, real(yp),'DisplayName', 'y''''(t) + .5 y''(t) + y(t)') 
    legend('show')
    xlabel('t\in[0,2\pi]')
    ylabel('y``(t) + .5 y`(t) + y(t)')
    title(sprintf('N = 2^{%i}', 2*i))
    pcount = pcount + 2;
end
order = zeros( length(error)-1, 1);
length(order)
for j = 1:(length(error)-1)
    order(j) = log(error(j+1) / error(j) );
end
figure(pcount+1)
hold on 
plot(1:(length(error)-1), order)
plot(1:length(error)-1, -1.6 + (1:length(error)-1) * .2)
ylabel('p(log(e1) - log(e2))')
title('Order of accuracy')

hold off
figure(pcount+2)
plot(error)
ylabel('Error')