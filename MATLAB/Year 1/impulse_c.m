% Part c MA(2)
function [] = impulse_c()
clc
wN = normrnd(0,1,80);
x_t(1) = wN(1);
x_t(2) = wN(1) + wN(2);
x_t(3) = wN(1) + wN(2) + wN (3);
for i =4:80
    x_t(i) = wN(i) + wN(i-1) + wN(i-2);
end

figure
subplot(2,1,1)
plot(x_t)

subplot(2,1,2)
storage = [1 .5 .4 zeros(1,77)];
plot(storage, 'o')

for i = 1: length(storage)
    line([i i] ,[0 storage(i)], 'Color', 'r')
end
end