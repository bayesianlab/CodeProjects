clear 
clc 

sims1 = 100;
lowLim1 = 0;
upLim1 = 1;
intervals1 = 4;
error1 = zeros(sims1, 1);
I1 = integral(@f1, lowLim1, upLim1);
h1 = zeros(sims1,1);
for j = 1:sims1
   error1(j) =  I1 - trapezoid(lowLim1, upLim1, j, @f1);
   h1(j) = (upLim1 - lowLim1) / j;
end

sims2 = 100;
upLim2 = 2*pi;
error2 = zeros(sims2, 1);
intervals2 = 2;
h2 = zeros(sims2,1);
for k = 1:sims2
   error2(k) =   0 - trapezoid(lowLim1, upLim2, intervals2 + k, @f2);
   h2(k) = (upLim2 - lowLim1) / k;
end
h2
sims3 = 100;
I3 = integral(@f3, lowLim1, upLim2)
x = linspace(0,2*pi, 100);
y = f3(x);
plot(x, y)
error3 = zeros(sims3, 1);
intervals3 = 0;
h3 = zeros(sims3,1);
for h = 1:sims3
    error3(h) = I3 - trapezoid(lowLim1, upLim2, intervals3 + h, @f3);
    h3(h) = (upLim2 - lowLim1) / h;
end

figure(1)
plot(log(h1(1:length(h1))), log(error1))
xlabel('Subinterval length h')
ylabel('Error log I - E')
figure(2)
plot(log(h2(1:length(h2))), log(error2))
xlabel('Subintervals length h')
ylabel('Error log I - E')
figure(3)
plot(log(h2(1:length(h2))), log(error3))
xlabel('Subinterval length h ')
ylabel('Error log I - E')


secondDeriv = @(x) (-2 ./ (1+x.^2).^2) + ((8.*x.^2) ./ (1 + x.^2).^3);

p1 = getPoints1(10^-2);
p2 = getPoints1(10^-3);
p3 = getPoints1(10^-4);
I1 - trapezoid(lowLim1, upLim1, p1, @f1);
I1 - trapezoid(lowLim1, upLim1, p2, @f1);
I1 - trapezoid(lowLim1, upLim1, p3, @f1);

