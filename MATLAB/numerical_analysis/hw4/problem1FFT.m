clear 
clc

format long
period = 2*pi;
N = 2^5;
x = linspace(0, 2*pi, N);
y =  1 + .5*sin(x) ;

f = @(x) 1 + .5*sin(x)
% fourier = fft(y, N);
% integral(f, 0, .5) 
% fourier(1)*(.5/N)
% err = abs(integral(f, 0, .5)  - fourier(1)*(.5/N))
errorStore = zeros(N,1);
for i = 1:N
    errorStore(i) = fftIntegrate(f, 0, x(i), N, 10^(-4), 1);
end
plot(x, errorStore)


 