.open dealscanDatabase.db
.mode column
.headers on

/*drop table if exists fp;
create table fp as 
select * from fac_price where BaseRate is not null;

drop table if exists flend;
create table flend as 
select f.FacilityID, f.PackageID, f.BorrowerCompanyID, lend.CompanyID, lend.BankAllocation, lend.LeadArrangerCredit
from facility as f
join lenders as lend 
on  f.FacilityID = lend.FacilityID;

drop table if exists flendp;
create table flendp as 
select  flend.*,fp.BaseRate 
from flend 
join fp 
on fp.FacilityID = flend.FacilityID;

drop table if exists relationship;
create table relationship as  
select BorrowerCompanyID, CompanyID, count(distinct PackageID) as totalRel 
from (
select * from flendp 
group by PackageID, BorrowerCompanyID, CompanyID
)
group by BorrowerCompanyID, CompanyID
order by totalRel desc;

drop table if exists onlyFixed;
create table onlyFixed as 
select * from flendp
where BaseRate="Fixed Rate";

drop table if exists fixedRelationships;
create table fixedRelationships as 
select *, count(distinct PackageID) as dPID 
from onlyFixed 
group by BorrowerCompanyID, CompanyID
order by dPID desc;*/

select relationship.*, fr.dPID as fixedRel
from relationship
left join fixedRelationships as fr 
on relationship.BorrowerCompanyID = fr.BorrowerCompanyID 
and relationship.CompanyID = fr.CompanyID
order by totalRel desc 
limit 20;


