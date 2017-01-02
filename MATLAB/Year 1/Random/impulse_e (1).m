% Part e ARMA(1, 2)
function [] = impulse_e()
phi = .8;
theta = .5;
upsilon = .4;
storage = [1 (phi + theta) (phi^2 +(phi*theta) + upsilon)...
    zeros(1,77)] ;

wN = normrnd(0,1,80);
x_t(1) = wN(1);
x_t(2) = wN(1) + theta*wN(2) + phi*x_t(1);
x_t(3) = wN(1) + theta*wN(2) + upsilon*wN(3)+phi*x_t(2);

for i = 4:77
   storage(i) = (phi^(i-2)) * (phi + upsilon + (phi^2)); 
   x_t(i) = wN(i)+ theta*wN(i-1) + upsilon*wN(i-2)+phi*x_t(i-1);
end

figure
subplot(2,1,1)
plot(x_t)

subplot(2,1,2)
plot(storage, 'o')
length(storage)

for i = 1: length(storage)
    line([i i] ,[0 storage(i)], 'Color', 'r')
end

end