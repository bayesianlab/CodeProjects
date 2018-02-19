function [zStar, fzstar] = chibml(a,b,mu,Sigma,sample, rrSims, rrBurnin)
[J,~] = size(Sigma);
[N,~] = size(sample);
reducedRuns = J - 2;
if isrow(mu) 
    mu = mu';
end
fzstar = zeros(J,1);
zStar = zeros(J,1);
precision = inv(Sigma);
Hxx = diag(precision);
sinoti = sqrt(Hxx.^(-1));
Hxy = zeros(J,J-1);
I = eye(J);
for j = 1:J
    notj = I([1:j-1, j+1:J], :);
    Hxy(j,:) = notj * precision(j, :)';
end
zStar(:) = mean(sample,1);
fzstar(1) = mean(  tnormpdf(a(1),b(1),...
                          cmean(mu(1), Hxx(1), Hxy(1,:), sample(:,2:J)', mu(2:J))',...
                          sinoti(1), zStar(1,1)  )  );
storemeans = zeros(rrSims,1);
rrSample = zeros(rrSims, J);
rrSample(:,1) = zStar(1,1);
updateVec = sample(N,:)';
for rr = 2:reducedRuns + 1
    for i = 1:rrSims
        keepjcmean = 0;
        for j = rr:J
            notj = I([1:j-1, j+1:J], :);
            munot = notj*mu;
            xnot = notj*updateVec;
            muj = cmean(mu(j), Hxx(j), Hxy(j,:), xnot, munot);
            if keepjcmean == 0
                storemeans(i) = muj;
                keepjcmean = keepjcmean + 1;
            end
          updateVec(j) = truncNormalRand(a(j), b(j), muj, sinoti(j));
        end
        rrSample(i, :) = updateVec';
    end
    if rr == reducedRuns + 1
        zstar(rr:rr+1,1) = mean(rrSample(rrBurnin:rrSims,rr:rr+1));
        fzstar(rr,1) = mean(tnormpdf(a(rr), b(rr),...
            storemeans(rrBurnin:rrSims), sinoti(rr), zStar(rr)));
        muj = cmean(mu(J), Hxx(J), Hxy(J,:), zStar(1:J-1,1), mu(1:J-1));
        fzstar(J,1) = mean(tnormpdf(a(J), b(J),...
            muj, sinoti(J), zStar(J)));
    else
        zStar(rr) = mean(rrSample(rrBurnin:rrSims,rr));
        fzstar(rr) = mean(tnormpdf(a(rr), b(rr), storemeans(rrBurnin:rrSims),...
            sinoti(rr), zStar(rr)));
    end
end
end


