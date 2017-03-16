.open testdb2.db
.headers on
.mode column

select * from testdb2 ;

drop table if exists innerQ;

create table innerQ
AS select PackageID, BorrowerCompanyID, CompanyID, count(*) as c 
from testdb2 
group by PackageID, CompanyID
order by PackageID asc;

.print
.print 'inner query'
select * from innerQ;

.print
.print 'test'
select BorrowerCompanyID, CompanyID, count(*) as testResults
from innerQ
group by BorrowerCompanyID, CompanyID
order by BorrowerCompanyID asc;

