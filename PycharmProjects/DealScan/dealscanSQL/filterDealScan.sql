.open flend.db
.mode column
.headers on

/* 
Change flend to be the table you want to find relationships for
 */

drop table if exists variableTableName;
create table variableTableName
AS select * 

/* To run the code on EVERYTHING uncomment this. No drops are made */
from flend;

/* If you have the oneArranger table already, use below instead of flend */
/*from oneArranger */ 
/* additional code for one lead arranger */

/* if you need to have one arranger change the 
   from flend to from flend where LeadArrangerCredit = 'Yes' as 
   commented out below. Run the other code below to make the oneArranger table
   Then change flend to oneArranger and use the rest of the queries. */
/*where LeadArrangerCredit='Yes';*/

/* Breaking up by SIC code */
/*where PrimarySICCode between 2000 and 3999;*/
/*where PrimarySICCode between 5000 and 5999;*/
/*where PrimarySICCode between 1500 and 1799;*/
/*where PrimarySICCode between 7000 and 8999;*/
/*where (PrimarySICCode between 0 and 5999) 
or (PrimarySICCode between 6800 and 9099) 
or (PrimarySICCode between 9730 and 9899);*/

/* Breaking up by inside or outside the USA */
/*from flend
where Country='USA';*/
/*from flend 
where Country != 'USA'; */

/* Code for exercise 3 */
/*from lessThan50;*/
/*from moreThan50;*/


/* Exercise 4 */
/*from flend
where DealPurpose = 'Corp. purposes';*/
/*from flend 
where DealPurpose = 'Work. cap.';*/
/*from flend
where DealPurpose = 'Trade finance';*/
/*from flend
where DealPurpose = 'Debt Repay.';*/
/*from flend
where DealPurpose = 'Real estate';*/
/*from flend
where DealPurpose = 'Takeover' 
or DealPurpose = 'LBO'; */

/*Exercise 5*/
/*from flend 
where Sales is null;*/

/*from salesNotNull;*/

/* Lower Quartile */
/*from salesNotNull  
where rowid between 1 and 455070;

/* Second Quartile */
/*from salesNotNull
where rowid between 455071 and 910140;*/

/* Third Quartile */
/*from salesNotNull
where rowid between 910141 and 1365210;*/

/* fourth Quartile */
/*from salesNotNull
where rowid > 1365210; */

select rowid, Sales from variableTableName limit 5;
select count(*) from variableTableName;

/*select rowid, Sales
from salesNotNull 
where rowid between 1 and 455070
order by Sales
limit 3;*/

/* Code to filter by one arranger and make a table for it */
/*drop table if exists arrangerPerPackageCounts;
create table arrangerPerPackageCounts
AS select ROWID, BorrowerCompanyID, CompanyID, LeadArrangerCredit, PackageID, BaseRate, BankAllocation, count(distinct CompanyID) as tooMany 
from variableTableName
group by PackageID, LeadArrangerCredit;

drop table if exists oneArranger;
create table oneArranger 
AS select * 
from arrangerPerPackageCounts
where tooMany = 1;*/

/* keep the not null sales table by itself */
/*drop table if exists salesNotNull; 
create table salesNotNull
as select *
from flend
where Sales is not null
order by Sales;*/


drop table if exists borrowerLenderRelTable;
create table borrowerLenderRelTable
AS select PackageID, BorrowerCompanyID, CompanyID, count(*) as nRelationships 
from (select * 
     from variableTableName
     group by PackageID, CompanyID)
group by BorrowerCompanyID, CompanyID;

drop table if exists fixRateCount;
create table fixRateCount
AS select BorrowerCompanyID, CompanyID, count(distinct PackageID) as nFixes
from (select * 
	from variableTableName
	where BaseRate = 'Fixed Rate'
	group by PackageId, CompanyID)
group by BorrowerCompanyID, CompanyID;

drop table if exists relationshipsWithFixedRates;
create table relationshipsWithFixedRates
AS select BorrowerCompanyID, CompanyID, 
	  nRelationships, nFixes, ifnull(ShareFixed, 0.0) as ShareFixed
    from (select borrowerLenderRelTable.BorrowerCompanyID, borrowerLenderRelTable.CompanyID, 
	  	borrowerLenderRelTable.nRelationships, fixRateCount.nFixes, 
	  	1.0*fixRateCount.nFixes/borrowerLenderRelTable.nRelationships as ShareFixed
   		from borrowerLenderRelTable
   		left join fixRateCount
   		on borrowerLenderRelTable.BorrowerCompanyID = fixRateCount.BorrowerCompanyID
   		and borrowerLenderRelTable.CompanyID = fixRateCount.CompanyID);
   
drop table if exists FixedRateShareTable;
create table FixedRateShareTable
AS select nRelationships, count(*) as R, sum(nFixes) as F, round(avg(ShareFixed), 6) as Share
from relationshipsWithFixedRates
group by nRelationships
order by nRelationships asc;

select nRelationships, R NumberOfNthTimeRelationship, F as TotalFixedRateLoans, Share as MeanShareFixed 
from FixedRateShareTable
order by R desc;

