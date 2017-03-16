.open tooMany.db
.mode column
.headers on
select BorrowerCompanyID, CompanyID, LeadArrangerCredit, PackageID, count(distinct CompanyID) as tm
from tooMany
group by PackageID, LeadArrangerCredit;

