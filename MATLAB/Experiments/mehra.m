clear
clc
beta = .99;
gamma = .5;
P1 = [.5,.5;.5,.5];
L = 1;
H = 1.02;
growth = [L^(1-gamma),H^(1-gamma)];
omega = (1 - (beta*P1).*growth*[1;1]).^(-1) .* (beta*P1.*growth) * [1;1]
rf = 1/ (beta* ((.5/L^gamma) + (.5/H^gamma)))
ps =[(beta* ((.5/L^gamma) + (.5/H^gamma))); (beta* ((.5/L^gamma) + (.5/H^gamma)))] 
retH = 197/196 * H
retL = 197/196 * L
disp(sprintf('\n'))

beta = .99;
gamma = 5;
P1 = [.5,.5;.5,.5];
L = 1;
H = 1.02;
growth = [L^(1-gamma),H^(1-gamma)];
omega = (1 - (beta*P1).*growth*[1;1]).^(-1) .* (beta*P1.*growth) * [1;1]
rf = 1/(beta* ((.5/L^gamma) + (.5/H^gamma)))
ps = [(beta* ((.5/L^gamma) + (.5/H^gamma))); (beta* ((.5/L^gamma) + (.5/H^gamma)))] 
retH = 20.96 / 19.96 * H
retL = 20.96 / 19.96 * L
disp(sprintf('\n'))

beta = .99;
gamma = 5;
P1 = [.75,.25;.25,.75];
L = 1;
H = 1.02;
growth = [L^(1-gamma),H^(1-gamma)];
omega = (1 - (beta*P1).*growth*[1;1]).^(-1) .* (beta*P1.*growth) * [1;1]
ps = [beta* ((P1(1,1)/L^gamma) + (P1(1,2)/H^gamma)) ; ...
    beta* ((P1(2,1)/L^gamma) + (P1(2,2)/H^gamma))]
rfL = 1/(beta* ((P1(1,1)/L^gamma) + (P1(1,2)/H^gamma)))
rfH = 1/(beta* ((P1(2,1)/L^gamma) + (P1(2,2)/H^gamma)))


retH = (33.6641+1)/33.6641*H
retL = (14.0275+1)/14.0275*L
retLH = (14.0275+1)/33.6641*H
retHL = (33.6641+1)/14.0275*L
% 24.9021/23.9021 *L



