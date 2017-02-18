clear
clc
N = 1000;

theta = (2*pi/N) .* (0:N);

plot( 3*1i*sin(theta) ./ ( 2 + cos(theta) ) )
z = @(z) (4.*z)/(6-2.*z) - .5*sqrt( ( (16.*z.^2) ./ (9- 6.*z + z.^2) )  + 4 ) ;
p = @(z) -1 - 1.5.*z + sqrt(1 + z + (9/4).*z.^2);

x = -1.5:0.1:.5;
[x', real(z(x))']
[x', p(x)']

% figure(2)
% hold on  
% plot( -2.*sqrt( 1- (exp(1i.*theta) ) ./ ( 3 + exp(-1i.*theta)) ) )
% plot( 2.*sqrt( 1- (exp(1i.*theta) ) ./ ( 3 + exp(-1i.*theta)) ) )

r1 = @(z) -(1/8)*(sqrt(9*z.^4 - 40*z.^2) - 3.*z + 4);
r2 = @(z) (1/8)*(sqrt(9*z.^4 - 40*z.^2) - 3.*z + 4);
x = -3:.1:3
[x', (r1(x)')]
[x', (r2(x)')]


a = @(theta) (3*exp(1i*theta) -1) ./ 4;
b = @(theta) exp(1i*theta);
c = @(theta) exp(1i*theta) - exp(2*1i*theta);
qr1 = @(theta, a, b, c) (-b(theta) + sqrt( b(theta).^2 - 4.*a(theta).*c(theta))) ./ 2.*a(theta)
qr2 = @(theta, a, b, c) (-b(theta) - sqrt( b(theta).^2 - 4.*a(theta).*c(theta))) ./ 2.*a(theta)
plot(theta, qr1(theta, a,b ,c))
hold on
plot( theta, qr2(theta, a, b,c))










