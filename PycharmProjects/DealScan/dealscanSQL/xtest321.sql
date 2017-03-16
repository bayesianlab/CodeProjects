.open xtest321.db
.mode column
.headers on
select * from xtest321 limit 10;


select BorrowerCompanyID, CompanyID, count(distinct PackageID)
from (select * 
from (select * 
from xtest321 
group by PackageID, CompanyID)
where BaseRate = 'Fixed Rate')
group by BorrowerCompanyID, CompanyID;

