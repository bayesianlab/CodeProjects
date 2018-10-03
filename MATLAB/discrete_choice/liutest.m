function [ output_args ] = liutest(a,b, z, R0, D0, Sims )
K = size(R0,1);
[~, SampleSize] = size(z)
newz = zeros(K,SampleSize);
for i = 1:Sims
    for t = 1:SampleSize
        newz(:,t)= geweke91(a,b,zeros(K,1),eye(K),1,0,z(t,:));
    end
        % Correlation Matrix Part
        
        WishartParameter = ystar*ystar';
        dSi = diag(diag(WishartParameter).^(-.5));
        WishartParameter = dSi*WishartParameter*dSi.*SubjectNumber;
        W = iwishrnd(WishartParameter, wishartDf);
        d0 = diag(W).^(.5);
        canD0 = diag(d0);
        canD0i = diag(d0.^(-1));
        canR = canD0i * W * canD0i;
        mhprob = min(0, .5*(CorrMatrixDimension + 1) *...
            (logdet(canR) - logdet(R0)) );
        if lu(i) < mhprob
            accept = accept + 1;
            R0 = canR;
            D0 = canD0;
        end


end

