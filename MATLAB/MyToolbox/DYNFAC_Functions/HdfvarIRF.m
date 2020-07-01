function [yt] = HdfvarIRF(st, beta, load, periods, shock)

Ft = zeros(length(st), periods);
b = beta(2:end);
yt = zeros(length(b),periods);
Ft(:,1) = shock;

for p = 2:periods
    Ft(:,p) = st*Ft(p-1) ; 
    yt(:,p)= b*yt(:,p-1) + load*Ft(:,p-1);
end

end

