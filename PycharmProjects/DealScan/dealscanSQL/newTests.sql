
.open flend.db
.headers on
.mode column 


drop table if exists relationshipsAndFixedRates;
create table relationshipsAndFixedRates
as select fixes.CompanyID, fixes.BorrowerCompanyID, finalCounts.testResults, fixes.numfixrates
from fixes, finalCounts 
where fixes.CompanyID = finalCounts.CompanyID 
and fixes.BorrowerCompanyID  = finalCounts.BorrowerCompanyID;

drop table if exists query1;
create table query1
AS select testResults, count(*) as numberFixed
from relationshipsAndFixedRates 
group by testResults
order by testResults asc;

drop table if exists query2;
create table query2
AS select testResults, count(*) as relationships
from finalCounts
group by testResults
order by testResults;

select query1.testResults as n, relationships, numberFixed 
from query1
join query2 on query1.testResults = query2.testResults;

select * from relationshipsAndFixedRates limit 20;
