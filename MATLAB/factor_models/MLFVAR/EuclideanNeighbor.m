function [D, cuts] = EuclideanNeighbor(Nsquares, ploton)
x = 0:1/Nsquares:1;
[u,~] = meshgrid(x);
nsqr2 =  Nsquares^2;
Middles = zeros(nsqr2,2);
D = zeros(nsqr2, nsqr2);
t = 0;
for g = 1:length(x)-1
    stop = g:g + 1;
    tu = u(stop,stop);
    for b = 1:length(x)-1
        move = b:b+1;
        tv = u(stop,move);
        p = polyshape([circshift(tv(:),3),tu(:)]);
        if ploton == 1
            plot(p, 'FaceColor', 'blue')
        end
        t = t + 1;
        [hor,vert] =centroid(p);
        Middles(t, :) = [hor,vert];
    end
end

for g = 1:Nsquares^2
    for q = g:Nsquares^2
        D(g,q) = sqrt(sum((Middles(g,:) - Middles(q,:)).^2));
    end
end
D = D + D';

Y = zeros(1,nsqr2);
Y(1) = 1;
cuts = [Y;fliplr(Y)] * eig(D).^(-1);
end