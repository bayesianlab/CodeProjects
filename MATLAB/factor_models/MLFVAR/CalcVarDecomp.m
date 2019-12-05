function [varianceDecomp] = CalcVarDecomp(InfoCell, Xt, beta, om, factors)
K = InfoCell{1};
levels=length(InfoCell);
K=K(2);
T= size(Xt,1)/K;
vd = zeros(K,3) ;
vareps = var(reshape(Xt*beta,K,T), [],2);
facCount = 1;
for k = 1:levels
    Info = InfoCell{1,k};
    Regions = size(Info,1);
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        vd(subsetSelect,k) = var(om(subsetSelect,k).*factors(facCount,:),[],2);
        facCount = facCount + 1;
    end
end
varianceDecomp = [vareps,vd];
varianceDecomp = varianceDecomp./sum(varianceDecomp,2);
end

