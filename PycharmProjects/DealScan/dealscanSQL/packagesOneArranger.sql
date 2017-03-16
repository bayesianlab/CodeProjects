.open dealscan.db
.mode column
.headers on
drop table if exists facilityLendersOnlyYes ;
create table facilityLendersOnlyYes
AS select facility.FacilityID, facility.PackageID, facility.BorrowerCompanyID, lenders.FacilityID, lenders.CompanyID, 
lenders.LeadArrangerCredit, lenders.BankAllocation  
from facility join lenders on facility.FacilityID = lenders.FacilityID
where lenders.LeadArrangerCredit = "Yes";

drop table if exists innerQ;
create table innerQ
AS select PackageID, BorrowerCompanyID, CompanyID, count(*) as c
from facilityLendersOnlyYes
group by PackageID, CompanyID;

drop table if exists results;
create table results 
AS select BorrowerCompanyID, CompanyID, count(*) as testResults
from innerQ
group by BorrowerCompanyID, CompanyID
order by testResults desc;

select * from results where testResults = 10;


/*select c, count(*) as b 
from counting
where c = 1;

select c, count(*) as b 
from counting
where c = 2;

select c, count(*) as b 
from counting
where c = 3;

select c, count(*) as b 
from counting
where c = 4;

select c, count(*) as b 
from counting
where c = 5;

select c, count(*) as b 
from counting
where c = 6;

select c, count(*) as b 
from counting
where c = 7;

select c, count(*) as b 
from counting
where c = 8;

select c, count(*) as b 
from counting
where c = 9;

select c, count(*) as b 
from counting
where c = 10;

select c, count(*) as b 
from counting
where c = 11;*/

drop table if exists numLenders;
create table numLenders
AS select count(distinct facilityLendersOnlyYes.CompanyID) as tally
from facilityLendersOnlyYes
group by facilityLendersOnlyYes.PackageID;

select count(tally) 
from numLenders
where tally = 1;


drop table if exists lendersOverTime;
create table lendersOverTime
AS select facilityLendersOnlyYes.CompanyID as uniqueLenders, PackageID
from facilityLendersOnlyYes
group by PackageID;
/* Helps test code !order by PackageID*/

drop table if exists lends;
create table lends as
select PackageID as pid, CompanyID as coid 
from facilityLendersOnlyYes
group by pid, coid;



drop table if exists nthLenders;
create table nthLenders
AS select uniqueLenders, count(*) as NthTimeLender
from lendersOverTime
group by uniqueLenders; 

/*select NthTimeLender, count(*) as nthLoan
from nthLenders
group by NthTimeLender
limit 10; */



