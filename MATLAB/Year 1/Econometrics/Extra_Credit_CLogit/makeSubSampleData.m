function [ newX ] = makeSubSampleData( Y, X, subsetSelection )

ly = length(Y);
[attributes, choices, obs]= size(X);

draw = round(subsetSelection * (choices - 1));
newX = zeros(attributes, draw, obs);
 
for i = 1:obs
    select = randperm(choices);
    select(select == Y(i)) = [];
    indices = select(1:draw);
    newX(:,:,i) = X(:, indices, i);
end


    

end

