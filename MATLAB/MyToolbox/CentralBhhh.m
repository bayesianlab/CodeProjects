function [grad, B] = CentralBhhh(guess, Function, y, X)
N = length(guess);
T = length(y);
score=zeros(N,T);
h = .5*sqrt(eps);
IN = eye(N);
B = zeros(N);
for t=1:T
    for n=1:N
        score(n,t) = (Function(guess+IN(:,n).*h, y(t), X(t,:) ) -...
            Function(guess-IN(:,n).*h, y(t), X(t,:)))./(2*h);
    end
    B = B + score(:,t)*score(:,t)';
end
grad = sum(score,2)./N;
B = B./N;
end

