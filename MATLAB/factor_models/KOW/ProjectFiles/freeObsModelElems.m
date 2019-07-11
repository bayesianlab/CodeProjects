function [ retval ] = freeObsModelElems( obsmodelsubset, RestrictionLevel )

[K,q] = size(obsmodelsubset);
t = 1:K;
if RestrictionLevel == 3
    retval = obsmodelsubset(t(t ~= 1),:)';
    retval = retval(:);
elseif RestrictionLevel == 2
    retval = obsmodelsubset(t(t ~= 1),:)';
    retval = retval(:);
    retval = [obsmodelsubset(1);retval];
elseif RestrictionLevel == 1
    retval = obsmodelsubset(t(t ~= 1),:)';
    retval = retval(:);
    retval = [obsmodelsubset(1); obsmodelsubset(1,2); retval];
else
    error('Invalid Restriction Level')
end
end

