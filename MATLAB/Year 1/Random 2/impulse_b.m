% Part b MA(1)
function [ ] = impulse_b()

wN = normrnd(0,1,80);
x_t(1) = wN(1);
for i =2:80
    x_t(i) = wN(i) + wN(i-1);
end

figure
subplot(2,1,1)
plot(x_t)

subplot(2,1,2)
storage = [1 .5 zeros(1,78)];
plot(storage, 'o')
for i = 1: length(storage)
    line([i i] ,[0 storage(i)], 'Color', 'r')
end
end