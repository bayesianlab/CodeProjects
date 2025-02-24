function [lastMeanWorld,lastHessianWorld, lastMeanRegion, ...
lastHessianRegion, lastMeanCountry, lastHessianCountry] =...
 kowBackupMeansAndHessians(SeriesPerCountry,Countries, EqnsPerBlock, blocks, ...
     blockSize, blocksRegion)
lastMeanWorld = zeros(EqnsPerBlock, blocks);
lastHessianWorld = reshape(repmat(eye(EqnsPerBlock),1,blocks), EqnsPerBlock,...
    EqnsPerBlock, blocks);
lastMeanRegion = zeros(blockSize, blocksRegion);
lastHessianRegion = reshape(repmat(eye(blockSize), 1, blocksRegion),...
    blockSize, blockSize, blocksRegion);
lastMeanCountry = zeros(SeriesPerCountry, Countries);
lastHessianCountry = reshape(repmat(eye(SeriesPerCountry), 1, Countries), ...
    SeriesPerCountry, SeriesPerCountry, Countries);


end

