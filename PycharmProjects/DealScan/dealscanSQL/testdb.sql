
.open testdb.db
.mode column
.headers on
.print 'everything'
select * from testdb;

drop table if exists innerQ;

create table innerQ
AS select PackageID, BorrowerID, CompanyID, count(*) as c 
from testdb 
group by PackageID, CompanyID
order by PackageID asc;

.print
.print 'inner query'
select * from innerQ;

.print
.print 'test'
select BorrowerID, CompanyID, count(*) as testResults
from innerQ
group by BorrowerID, CompanyID
order by BorrowerID asc;
