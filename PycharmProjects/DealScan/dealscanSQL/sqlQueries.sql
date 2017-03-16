.open dealscan.db

drop table if exists leadArranger;
create table leadArranger 
AS select FacilityID, CompanyID, BankAllocation, LeadArrangerCredit 
from lenders 
where LeadArrangerCredit = "Yes";

drop table if exists oneLeadPerFacility;
create table oneLeadPerFacility
AS select FacilityID, Count(CompanyID) as CountOfCompanyID 
from leadArranger
group by FacilityID
having CountOfCompanyID = 1;

drop table if exists pairsByFacility;
create table pairsByFacility
AS select oneLeadPerFacility.FacilityID, facility.PackageID, facility.BorrowerCompanyID, lenders.CompanyID 
from (oneLeadPerFacility left join facility on oneLeadPerFacility.FacilityID == facility.FacilityID)
left join lenders
on oneLeadPerFacility.FacilityID = lenders.FacilityID;

drop table if exists packagesOneLeadPerFacility;
create table packagesOneLeadPerFacility
AS select pairsByFacility.PackageID as PackageID, pairsByFacility.CompanyID as CompanyID, pairsByFacility.BorrowerCompanyID as BorrowerCompanyID
from pairsByFacility
group by pairsByFacility.PackageID, pairsByFacility.CompanyID, pairsByFacility.BorrowerCompanyID;

pragma table_info(packagesOneLeadPerFacility);
drop table if exists oneLeadPerPackage;
create table oneLeadPerPackage
AS select PackageID, count(CompanyID) as countOfBank
from packagesOneLeadPerFacility
group by PackageID
having countOfBank = 1; 

select count(PackageID) from oneLeadPerPackage;

