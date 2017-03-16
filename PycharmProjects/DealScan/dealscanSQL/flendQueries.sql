.open flend.db
.mode column
.headers on

select count(nRelationships) as R , count(fixedRates) as F, count(fixedRates)*1.0/count(nRelationships) 
from totalRelAndFixedRates
group by nRelationships
order by nRelationships asc;
