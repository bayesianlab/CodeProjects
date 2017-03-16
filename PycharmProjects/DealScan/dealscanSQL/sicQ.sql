.open flend.db
.headers on
.mode column



drop table if exists manuRelationships;
create table manuRelationships
AS select PackageID, BorrowerCompanyID, CompanyID, count(*) dups
from manu
group by PackageID, CompanyID
order by PackageID;
select * from manuRelationships limit 10; 

drop table if exists manuCounts;
create table manuCounts
AS select BorrowerCompanyID, CompanyID, count(*) as num 
from manuRelationships
group by BorrowerCompanyID, CompanyID;

/*select num, count(num) 
from manuCounts 
group by num; */
