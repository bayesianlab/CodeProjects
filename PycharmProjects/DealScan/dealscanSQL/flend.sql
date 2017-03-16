.open flend.db
.headers on
.mode column

.print 'Rows' 
select count(PackageID) as RowNumber from flend;

drop table if exists fixedRateLoanCount;
.print 'Fixed rate loan count'
create table fixedRateLoanCount 
as select BorrowerCompanyID, CompanyID, count(distinct PackageID) as fixedRates
from (select * 
	from flend 
	where BaseRate = 'Fixed Rate'
	group by PackageID, CompanyID)
group by BorrowerCompanyID, CompanyID
order by fixedRates desc;
.print 'table fixedRateLoanCount'
select BorrowerCompanyID, CompanyID, fixedRates from fixedRateLoanCount limit 10;

.print 
.print 'Relationships'
drop table if exists relationships;
create table relationships
AS select PackageID, BorrowerCompanyID, CompanyID, count(*) duplicates
from orderedTable
group by PackageID, CompanyID
order by PackageID;
.print 'Table created, table relationships sample below'
select * from relationships limit 5;

.print 
.print 'Creating table that has the relationships through time'
drop table if exists borrowerLenderRelationships;
create table borrowerLenderRelationships
AS select BorrowerCompanyID, CompanyID, count(*) as nRelationships 
from relationships
group by BorrowerCompanyID, CompanyID
order by BorrowerCompanyID asc;
.print 'table created'
select * from borrowerLenderRelationships 
order by nRelationships desc 
limit 10;

drop table if exists numberRelationships;
create table numberRelationships
AS select nRelationships, count(nRelationships) as numBorrowerLenderWithNrelationships
from borrowerLenderRelationships 
group by nRelationships 
order by nRelationships asc;

.print
.print 'selection from numberRelationships'
select * from numberRelationships limit 20;

drop table if exists totalRelAndFixedRates;
create table totalRelAndFixedRates
AS select borrowerLenderRelationships.BorrowerCompanyID, borrowerLenderRelationships.CompanyID, borrowerLenderRelationships.nRelationships, fixedRateLoanCount.fixedRates 
from borrowerLenderRelationships 
left join fixedRateLoanCount 
on borrowerLenderRelationships.BorrowerCompanyID = fixedRateLoanCount.BorrowerCompanyID and borrowerLenderRelationships.CompanyID = fixedRateLoanCount.CompanyID
order by nRelationships desc;

.print 
.print 'totalRelAndFixedRates'
select * from totalRelAndFixedRates limit 5;

drop table if exists manu;
create table manu
as select PackageID, BorrowerCompanyID, CompanyID, BaseRate, cast(PrimarySICCode as int) as PrimarySICCode
from flend
where PrimarySICCode between 2000 and 3999;

.print 
.print 'table manu'
select * from manu limit 5;

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

select * from manuCounts order by num desc limit 5;



