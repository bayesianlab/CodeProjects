# dealscan
package <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/package.xlsx")
facility <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan//facility.xlsx")
lenders <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/lenders.xlsx")
facility_price <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/current_facility_pricing.xlsx")

p <- package[, c(1,2,3)]
f <- facility[, c(1, 2,3, 5:7)]
lend <- lenders[, c(1,2,3, 5, 7)]

flend <- merge(f, lend, by="FacilityID")
flendp <- merge(flend, facility_price, by ="FacilityID")
orgOfCols <- c('FacilityID', 'PackageID', 'BorrowerCompanyID', 'Company', 'CompanyID', 'Lender', 'FacilityStartDate', 
  'FacilityEndDate', 'BankAllocation', 'LeadArrangerCredit')
flend <- flend[, orgOfCols]
write_csv(flend, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan//flend.csv")
flend <- flend[-which(is.na(flend$BankAllocation)), ]
write_csv(flend, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/flendDroppedAllocations.csv")


flend$PackageID <- factor(flend$PackageID)
flend$BorrowerCompanyID <- factor(flend$BorrowerCompanyID)

table(flend[flend$BorrowerCompanyID == '3804', 'CompanyID'])
flend[flend$BorrowerCompanyID == '3782', ]

fakeDealScan <- as.data.frame(matrix(0, nrow=10, ncol=8))
colnames(fakeDealScan) <- colnames(flend)
fakeDealScan$FacilityID <- 1:10
fakeDealScan$PackageID <- c(100, 100, 100, 200, 200, 400, 400, 600, 600, 900)
fakeDealScan$BorrowerCompanyID <- c(21,21,21, 22, 22, 23, 23, 24, 24, 21)
fakeDealScan$CompanyID <- c(1,2,1,2,2,3,3,4,4,1)
write_csv(fakeDealScan, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/fake.csv")
fakeDealScan[fakeDealScan$BorrowerCompanyID ==1 , 'CompanyID']
