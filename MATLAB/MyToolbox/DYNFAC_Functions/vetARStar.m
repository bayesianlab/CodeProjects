function [omArStar] = vetARStar(omArStar, yt, xt, Ft, beta, obsVariance,  delta0, Delta0, subsetIndices, FtIndexMat)
[K,T]=size(yt);
lags=size(omArStar,2);
MAXN = 75;
for jj = 1:K
    tempI = subsetIndices(jj,:);
    tempy = yt(jj,:);
    tempx=[xt(tempI,:),Ft(FtIndexMat(jj,:),:)'];
    tempobv = obsVariance(jj);
    test = omArStar(jj,:);
    S0draw = initCovar(test, tempobv);
    [~, pd] = chol(S0draw,'lower');
    if pd ~= 0
        mut = reshape(tempx*beta(:,jj),1,T);
        epsilont = (tempy- mut);
        Lagepsilont = lagMat(epsilont, lags)';
        epsilont = epsilont(:,lags+1:end)';
        % Propose a candidate
        proposalVariance = ((Delta0\eye(lags)) +( Lagepsilont'*Lagepsilont)./tempobv )\eye(lags);
        proposalMeanN = proposalVariance*( ( Delta0\delta0')+ (Lagepsilont'*epsilont)./tempobv);
        L = chol(proposalVariance,'lower');
        c=0;
        unitCircle = 2;
        while unitCircle >=1
            c = c + 1;
            draw = (proposalMeanN + L*normrnd(0,1,lags,1))';
            Phi = [draw; eye(lags-1), zeros(lags-1,1)];
            unitCircle = sum(abs(eig(Phi)) >= 1);
            if c == MAXN
                fprintf('Unsuccessful\n')
                omArStar(jj,:)=test;
                break
            end
        end
    end
end
end

