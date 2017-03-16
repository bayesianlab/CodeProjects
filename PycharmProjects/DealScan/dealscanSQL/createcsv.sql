.mode csv
.headers on
.once 'usa.csv'
select nRelationships, R NumberOfNthTimeRelationship, F as TotalFixedRateLoans, Share as MeanShareFixed 
from FixedRateShareTableUSA
order by R desc;
