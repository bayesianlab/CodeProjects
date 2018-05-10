function [responses] = BvarImpulse(A, D0inv,shock, periodsout)
[K, L] = size(A);
p = (L-1)/K;
yt = D0inv*shock;
z = yt;
responses = zeros(periodsout, K);
responses(1, :) = yt';
for i = 1:periodsout
    if p == 1
        X = [1;z];
        yt = A*X;
        responses(i+1, :) = yt';
        z(1:K) = yt;
    else
        if i < p
           X = [1, z', zeros(1,K*(p-i))]';
           yt = A*X;
           responses(i+1, :) = yt';
           z = [yt;z];
        else
            X = [1;z];
            yt = A*X;
            responses(i+1, :) = yt';
            z(1:K)
            z(K+1:2*K) = z(1:K);
            z(1:K) = yt;
        end
    end
end
end

