function [Matrix] = InverseCommute(Vector, RowsMatrix)
K = length(Vector);
if K == 1
    Matrix = Vector;
elseif (RowsMatrix*(RowsMatrix+1)*.5) ~= K
    error('Incorrect input.')
else
    Matrix = zeros(RowsMatrix*RowsMatrix, K);
    rows = 1:RowsMatrix;
    remainingCols = K ;
    countCols = 0;
    for k = 1:RowsMatrix
        Diagonal = ones(RowsMatrix,1);
        DiagonalIndex = 1-k;
        SizeBlockCols =  RowsMatrix - (k-1);
        Block = full(spdiags(  Diagonal, DiagonalIndex, RowsMatrix, SizeBlockCols));
        remainingCols = remainingCols - size(Block,2);
        paddingL = zeros(RowsMatrix, countCols);
        countCols = countCols + RowsMatrix-(k-1);
        paddingR = zeros(RowsMatrix, remainingCols);
        Matrix(rows + RowsMatrix*(k-1),:) = [paddingL, Block, paddingR];
    end
end
end

