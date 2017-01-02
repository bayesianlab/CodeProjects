function [ cur_t ] = updateObservations( X, p)
[r,c] = size(X);
cur_t = zeros(c*p,1);
cnt = 0;
lag = p;
index = 1;
for col = 1:c
    col_vec = X(:,col);
    while lag >=1
        cur_t(index) = col_vec(r-cnt);
        cnt = cnt + 1;
        lag = lag -1;
        index = index + 1;
    end
    lag = p;
    cnt = 0;
end
cur_t = [1, cur_t'];
end

