function [ proposal ] = optimProposeT(themean, V, df)
    w1 = sqrt(chi2rnd(df,1)/df);
    VLower = chol(V,'lower');
    proposal  = themean + VLower\normrnd(0,1,length(themean),1)./w1 


end

