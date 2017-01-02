% Part d ARMA(1,1)
function[] = impulse_d()
clc
wN = normrnd(0,1,80);
phi = .999;
theta = .4;
x_t(1) = wN(1);
x_t(2) = phi* x_t(1) + wN(2) - wN(1);
storage = [1 (phi-theta) phi*(phi-theta)];
for i = 3:length(wN)
    x_t(i) = (phi* x_t(i-1)) + wN(i) - wN(i-1);
    storage(i) = (phi^(i-1)) * (phi-theta);
   
end

figure
subplot(2,1,1)
plot(x_t)

subplot(2,1,2)
plot(storage, 'o')


for i = 1: length(storage)
    line([i i] ,[0 storage(i)], 'Color', 'r')
end
end


