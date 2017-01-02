
clc 
x = [travelcost, traveltime];
lx = length(x);
dat = zeros(3,5, lx/3);
datForProFunction = zeros(lx/3, 5, 3);
y = zeros(lx/3,1);
select = 1;
iden = eye(3);
iden = repmat(iden, 1191,1);
iden(:,3) = trainpass;
x = [iden x];

for i = 1:lx/3
    y(i) = choice(select);
    datForProFunction(i, :, :) =  reshape(x(select:select + 2,:)', 1, 5, []);
    select = select + 3;
    
end
select= 1;
for i = 1:lx/3

    dat(:,:, i) = x(select:select+2, :);
    select = select + 3;
    
end

% datForProFunction(1:10, : , :)

bGuess = [0,0,0,0,0]';
options = optimset('Display', 'off', 'MaxIter', 15e3, 'TolX',1e-8,'Tolfun',1e-8);
[clogits, ~,~,~,~,hu] = fminunc('clogit', bGuess, options, [], y, [], datForProFunction, 3);

[myfnq, ~,~,~,~,~] = fminunc('condlogit', bGuess, options, y, dat, 0);
str = sprintf('The internet code and my code:\nClogit\tMine');
disp(str )
disp([clogits, myfnq])