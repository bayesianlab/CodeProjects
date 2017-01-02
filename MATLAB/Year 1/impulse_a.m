function [] = impulse_a(  )
% Part a, MA(0)
%% 
figure
subplot(2, 1, 1)
plot(normrnd(0,1,1,80))

subplot(2, 1, 2)
storage = [1 zeros(1,80)];
plot(storage, 'o')
for i = 1: length(storage)
    line([i i] ,[0 storage(i)], 'Color', 'r')
end
end
