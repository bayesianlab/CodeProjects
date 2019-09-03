# dealscan
library(readxl)
library(readr)
library(sqldf)
package <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/package.xlsx")
facility <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan//facility.xlsx")
lenders <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/lenders.xlsx")
facility_price <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/current_facility_pricing.xlsx")
company <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/company.xlsx")
p <- package[, c('PackageID','BorrowerCompanyID', 'DealPurpose')]
f <- facility[, c(1,2,3, 5:7)]
lend <- lenders[, c(1,2,3, 5, 7)]
fp <- facility_price[, c(1,2)]
comp <- company[,c("CompanyID", "PrimarySICCode", "Country", "Sales")]
colnames(comp)[1] <- "BorrowerCompanyID"
flend <- merge(f, lend, by="FacilityID")
flend <- merge(flend, fp, by="FacilityID")
flend <- merge(flend, comp, by="BorrowerCompanyID")
flend <- merge(flend, p[, c('PackageID', 'DealPurpose')], by="PackageID")
flend$PackageID <- as.integer(flend$PackageID)
flend$FacilityID <- as.integer(flend$FacilityID)
flend$BorrowerCompanyID <- as.integer(flend$BorrowerCompanyID)
flend$CompanyID <- as.integer(flend$CompanyID)
flend$FacilityEndDate <- as.integer(flend$FacilityEndDate)
flend$FacilityStartDate <- as.integer(flend$FacilityStartDate)
flend$PrimarySICCode <- as.integer(flend$PrimarySICCode)
write_csv(flend, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/dealscanSQL/flend.csv")

sel <- c('CompanyID', 'BaseRate', 'PackageID')
orgOfCols <- c('FacilityID', 'PackageID', 'BorrowerCompanyID', 'Company', 'CompanyID', 'Lender', 'FacilityStartDate', 
  'FacilityEndDate', 'BankAllocation', 'LeadArrangerCredit', 'BaseRate')


flend <- flend[, orgOfCols]

flend$PackageID <- as.integer(flend$PackageID)
flend$FacilityID <- as.integer(flend$FacilityID)
flend$BorrowerCompanyID <- as.integer(flend$BorrowerCompanyID)
flend$CompanyID <- as.integer(flend$CompanyID)
flend$FacilityEndDate <- as.integer(flend$FacilityEndDate)
flend$FacilityStartDate <- as.integer(flend$FacilityStartDate)
flend$PrimarySICCode <- as.integer(flend$PrimarySICCode)
yes <- flend[which(flend$LeadArrangerCredit == 'Yes'), ]
write_csv(flend, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/flendMessyTime.csv")

write_csv(flend, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/flendNoDrops.csv")

# flend$PackageID <- factor(flend$PackageID)
# flend$BorrowerCompanyID <- factor(flend$BorrowerCompanyID)


fakeDealScan <- flend[1:100, ]
fakeDealScan$FacilityID <- as.integer(fakeDealScan$FacilityID)
fakeDealScan$PackageID <- as.integer(fakeDealScan$PackageID)
fakeDealScan$BorrowerCompanyID <- as.integer(fakeDealScan$BorrowerCompanyID)
fakeDealScan$CompanyID <- as.integer(fakeDealScan$CompanyID)
fakeDealScan$FacilityStartDate <- as.integer(fakeDealScan$FacilityStartDate)
fakeDealScan$FacilityEndDate <- as.integer(fakeDealScan$FacilityEndDate)

fakeDealScan[100, 3] <- as.integer(33181)
fakeDealScan[100, 5] <- as.integer(6827)
fakeDealScan[12, 3] <- as.integer(1)
fakeDealScan[12, 5] <- as.integer(7827)
fakeDealScan[5, 10] <- "Yes"
write_csv(fakeDealScan, path="/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/DealScan/fake.csv")
fakeDealScan[which(fakeDealScan$PackageID %in% keepThese$keep), ]
head(flend)
flend[flend$CompanyID == 5893 & flend$BorrowerCompanyID == 24, c('PackageID', 'CompanyID', 'BorrowerCompanyID')]
factor(x$PackageID)
fixedAndRelation <- read_csv("~/Google Drive/CodeProjects/PycharmProjects/DealScan/fixedAndRelation.csv")
tab <- fixedAndRelation
tab$n <- tab$n - 1
p <- tab$numberFixed/tab$relationships 
tab <- as.data.frame(cbind(tab, p))
write_csv(tab, "~/Google Drive/CodeProjects/PycharmProjects/DealScan/res.csv")
x <- flend[flend$BorrowerCompanyID == 9075 & flend$CompanyID == 9075, c('PackageID', 'BorrowerCompanyID', 'CompanyID', 'BaseRate')]
c <-0 
x <- x[x$BaseRate == 'Fixed Rate', ]
x$PackageID <- factor(x$PackageID)
table(x$PackageID)
x
for(el in levels(x$PackageID)){
  z <- factor(x[x$PackageID==el, "BaseRate"])
  for(i in levels(z)){
    if(i == "Fixed Rate"){
      # print(i)
      c<-c+1
    }
  }
}
write_csv(x, "~/Google Drive/CodeProjects/PycharmProjects/DealScan/xtest321.csv")
print(c)
"Fixed Rate Fixed Rate" == "Fixed Rate"
manuCounts <- read_csv("~/Google Drive/CodeProjects/PycharmProjects/DealScan/manuCounts.csv")
manuCounts$num <- manuCounts$num - 1
write_csv(manuCounts, "~/Google Drive/CodeProjects/PycharmProjects/DealScan/manuCounts.csv")

testJoin <- as.data.frame(matrix(cbind(1:25, seq(10, 250, 10), as.integer(runif(25, 500, 1000))), ncol = 3))
colnames(testJoin) <- c('BorrowerCompanyID', 'CompanyID', 'fixedRates')
testJoin2 <- as.data.frame(matrix(cbind(1:50, seq(10, 250, 50), as.integer(runif(50, 500, 1000))), ncol = 3))

flend[flend$PackageID == 102, ]

tooManyLeadsTest <- as.data.frame(matrix(cbind(rep(566, 10), c(rep(2,5), rep(6,5)), rep(102, 10), rep('Yes', 10)  ), ncol = 4)  )
colnames(tooManyLeadsTest) <-c('BorrowerCompanyID', 'CompanyID', 'PackageID',  'LeadArrangerCredit')
write_csv(tooManyLeadsTest, "~/Google Drive/CodeProjects/PycharmProjects/DealScan/dealscanSQL/tooManyLeads.csv")


library(ggplot2)
rel_fix <-  read_csv("~/Google Drive/CodeProjects/PycharmProjects/DealScan/dealscanSQL/rel_fix.csv")
relation <- rel_fix$nRelationships
share <- rel_fix$ShareFixed
lm(share~ relation)
qplot(relation, share) + geom_jitter()

ggplot(rel_fix) + geom_point(aes(x=rel_fix$nRelationships, y=rel_fix$ShareFixed))


