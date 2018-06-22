function [Fdel, Bt] = testBhhh(b,y,X)
score = testmax(b,y,X);
Fdel = (sum(score)/length(y))';

Bt = zeros(length(b), length(b));
for i = 1 : length(y)
    Bt = Bt + (score(i,:)' * score(i,:));
end
Bt = Bt/length(y);
end