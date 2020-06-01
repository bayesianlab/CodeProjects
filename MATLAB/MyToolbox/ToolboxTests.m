clear;clc;
S = createSigma(.5,2);
H = vechMatrixMaker(S,-1);
if vech(S,-1) == H*S(:)
    disp('Test PASSED')
end
H = vechMatrixMaker(S,0);
stest = sum(H*S(:)==vech(S,0) );
if stest == 3
    disp('Test PASSED')
else
    disp('Test FAILED')
end

S = createSigma(.5,3);
H = vechMatrixMaker(S,0);
stest = sum(H*S(:)==vech(S,0) );
if stest == length(vech(S,0))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

S = createSigma(.5,4);
H = vechMatrixMaker(S,0);
stest = sum(H*S(:)==vech(S,0) );
if stest == length(vech(S,0))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

S = createSigma(.5,4);
d = -1;
H = vechMatrixMaker(S,d);
stest = sum(H*S(:)==vech(S,d) );
if stest == length(vech(S,d))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

S = createSigma(.5,10);
d = -1;
H = vechMatrixMaker(S,d);
stest = sum(H*S(:)==vech(S,d) );
if stest == length(vech(S,d))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

S = createSigma(.5,30);
d = -1;
H = vechMatrixMaker(S,d);
stest = sum(H*S(:)==vech(S,d) );
if stest == length(vech(S,d))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

for d = -9:0
    S = createSigma(.5,10);
    d = -3;
    H = vechMatrixMaker(S,d);
    stest = sum(H*S(:)==vech(S,d) );
    if stest == length(vech(S,d))
        disp('Test PASSED')
    else
        disp('Test FAILED')
    end
end

K = 3;
d=0;
Q = unVechMatrixMaker(K,d);
S=  createSigma(.5,K);
vs = vech(S,0);
[K,~] = size(S);
Qvs = reshape(Q*vs, K, K);
Qvs = Qvs + tril(Qvs, -1)';
if (K*K) == sum(sum(S == Qvs))
    disp('Test PASSED')
else
    disp('Test FAILED')
end

K = 2;
d=0;
Q = unVechMatrixMaker(K,d);
S=  createSigma(.5,K);
vs = vech(S,0);
[K,~] = size(S);
Qvs = reshape(Q*vs, K, K);
Qvs = Qvs + tril(Qvs, -1)';
if (K*K) == sum(sum(S == Qvs))
    disp('Test PASSED')
else
    disp('Test FAILED')
end




for d = -4:0
    K = 5;
    Q = unVechMatrixMaker(K,d);
    S=  createSigma(.5,K);
    vs = vech(S,d);
    [K,~] = size(S);
    if d == 0
        extdia = zeros(K);
    else
        dd = d+1;
        dia = dd:abs(dd);
        extdia = full(spdiags(spdiags(S, dia), dia, K,K));
    end
    T = reshape(Q*vs,K,K) + extdia;
    if d == 0
        T = tril(T,-1)' + T;
        if (K*K) == sum(sum(S == T ))
            disp('Test PASSED')
        else
            disp('Test FAILED')
        end
    else
        T= T + tril(T,d)';
        if (K*K) == sum(sum(S == T ))
            disp('Test PASSED')
        else
            disp('Test FAILED')
        end
    end
end

