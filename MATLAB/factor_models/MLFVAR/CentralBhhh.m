function [grad, B] = CentralBhhh(guess, Function, y, X,  h)
N = length(guess);
T = length(y);
oscore=zeros(N,N);
score=zeros(N,T);
keepscore= score;
tguess= guess;
ttguess = guess;
for n=1:N
    tguess(n) = guess(n) + h;
    ttguess(n) = guess(n) - h;
    for t=1:T     
        score(n,t) = (Function(tguess, y(t), X(t,:) ) - Function(ttguess, y(t), X(t,:)))./(2*h);
    end
    tguess(n) = guess(n) - h;
    ttguess(n) = guess(n) +h;
end
grad = sum(score,2)./N;
B = (score*score')./N;
end

