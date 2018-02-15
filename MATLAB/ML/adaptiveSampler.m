function [sample] = adaptiveSampler(a,b, alpha, beta, mu, Sigma,N, burnin, blocks)
[J,~] = size(Sigma);
sample = zeros(N,J);
[sample(1:burnin, :), gwk] = warmup(a,b, alpha, beta, mu,Sigma,burnin);
if gwk == 1
    rz = autocor(sample(1:burnin,:),1);
    ghk = 0;
else
    reta = autocor(sample(1:burnin, :), 1);
    ghk = 1;
end
switches = floor((N - burnin)/blocks);
remainder = (N-burnin) - blocks*switches;
startIndex = 1;
sample = zeros(switches*blocks + remainder, J);
lastPass = sample(burnin,:);
weight = .5*ones(J,1);
for i = 1:switches
    endIndex = i*blocks;
    if gwk == 1 && ghk == 1
        if sum(rz > reta) == J
            sample(startIndex:endIndex , :) =...
                tmultnormrndEta(a,b, alpha, beta, mu,Sigma,blocks);
            lastPass = sample(endIndex,:);
            reta = autocor(sample(burnin:endIndex, :),1);
            startIndex = endIndex + 1;
        elseif sum(reta > rz) == J
            sample(startIndex:endIndex, :) = ...
                tmultnormrnd(a,b,mu,Sigma,blocks, lastPass);
            lastPass = sample(endIndex,:);
            rz = autocor(sample(burnin:endIndex, :), 1);
            startIndex = endIndex + 1;
        else
            peta = (weight'*rz)*(weight'*rz + weight'*reta)^(-1);
            if peta < unifrnd(0,1)
                sample(startIndex:endIndex , :) =...
                    tmultnormrndEta(a,b, alpha, beta, mu,Sigma,blocks);
                lastPass = sample(endIndex,:);
                reta = autocor(sample(burnin:endIndex, :), 1);
                
                startIndex = endIndex + 1;
            else
                sample(startIndex:endIndex, :) = ...
                  tmultnormrnd(a,b,mu,Sigma,blocks, lastPass);
                lastPass = sample(endIndex,:);
                rz = autocor(sample(burnin:endIndex, :), 1);
                startIndex = endIndex + 1;
            end  
        end
        startIndex = endIndex + 1;
    elseif unifrnd(0,1) < .5
        sample(startIndex:endIndex, :) = ...
            tmultnormrnd(a,b,mu,Sigma,blocks, lastPass);
        rz = autocor(sample(startIndex:endIndex, :), 1);
        lastPass = sample(endIndex,:);
        gwk = 1;
        startIndex = endIndex + 1;
    else
        sample(startIndex:endIndex , :) = ...
            tmultnormrndEta(a,b, alpha, beta, mu,Sigma,blocks);
        reta = autocor(sample(startIndex:endIndex, :), 1);
        lastPass = sample(endIndex,:);
        ghk = 1;
        startIndex = endIndex + 1;
    end
end
if remainder > 0
    if (ghk == 1) && (gwk == 1)
        peta = (weight'*rz)*(weight'*rz + weight'*reta)^(-1);
        if peta < unifrnd(0,1)
            sample(startIndex:(N-burnin) , :) =...
                tmultnormrndEta(a,b, alpha, beta, mu,Sigma,remainder);
        else
            sample(startIndex:(N-burnin), :) = ...
              tmultnormrnd(a,b,mu,Sigma,remainder, lastPass);
        end 
    else
        if unifrnd(0,1) < .5
        sample(startIndex:N-burnin, :) = ...
            tmultnormrnd(a,b,mu,Sigma,remainder, lastPass);
        else
        sample(startIndex:N-burnin, :) = ...
            tmultnormrndEta(a,b, alpha, beta, mu,Sigma,remainder);
        end
    end
end
end

