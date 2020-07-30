function [alpha] = mvp_SigmaGstep(SigmaStar, Sigmag, ztg, sig0, Sig0, unvech,...
    vechIndex, storeMeans, storeVars)
K=size(ztg,1);
df = 15;
star = vech(SigmaStar);
G = size(Sigmag,2);

storesks = zeros(K-1,1);
for k = 1:K-1
    vindx = vechIndex(k,1) : vechIndex(k,2);
    storesks(k) = std(Sigmag(vindx),[],2);
end

for g = 1:G
    ksum = 0;
    sg = Sigmag(:,g);
    for k = 1:K-1
        vindx = vechIndex(k,1) : vechIndex(k,2);
        nsubk = length(vindx);
        sgfree = sg(vindx);
        
        bk = storesks(k)*G^(-1/(1+nsubk));
        ksum = ksum + -log(bk) + logmvnpdf( (star(vindx) - sgfree)/bk );
    end
    storeksums(g) = ksum;
end
logAvg(storesksums)
end

