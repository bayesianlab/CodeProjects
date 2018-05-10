%%% True values [1,.4,-.5,.6,.9]'
%%% Cut points are [-2 0 2]
%%% 1000 simulations, 100 burned
load('b')
load('g')
b1 = b(:,1);
b2 = b(:,2);
b3 = b(:,3);
b4 = b(:,4);
b5 = b(:,5);
g2 = g(:,2);
g3 = g(:,3);
figure(1)
subplot(3,3,1)
hist(b1,25)
title('\beta_1')
subplot(3,3,2)
hist(b2,25)
title('\beta_2')
subplot(3,3,3)
hist(b3,25)
title('\beta_3')
subplot(3,3,4)
hist(b4,25)
title('\beta_4')
subplot(3,3,5)
hist(b5,25)
title('\beta_5')
subplot(3,3,6)
hist(g2,25)
title('\gamma_2')
subplot(3,3,8)
hist(g3,25)
title('\gamma_3')