function [condmean, condvar] = kowConditionalParametersT(mui, Hii, Hinoti, Hnotinoti, xnot, munot, df1, df2)
demurestrict = xnot-munot;
condmean = mui - Hii\Hinoti *(demurestrict);
condvar = ((df1 + (demurestrict'*Hnotinoti*demurestrict))/ df2)\Hii;

end

