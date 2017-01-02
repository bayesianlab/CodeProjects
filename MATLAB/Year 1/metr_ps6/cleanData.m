function [ vector ] = cleanData( vector, cutoff )
for i = 1: length(vector)
   if vector(i,1) < cutoff
      vector(i,1) = 0 ;
   end
end

end

