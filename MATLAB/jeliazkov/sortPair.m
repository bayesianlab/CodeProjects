function [ array ] = sortPair( array, c )
[r,~] = size(array);
for i = r:-1:1
   for j = 2:i
       if array(j-1, c) > array(j,c)
           tmp = array(j-1,:);
           array(j-1,:) = array(j,:);
           array(j,:) = tmp;
       end
   end
end
end

