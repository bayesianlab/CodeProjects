library(readxl)
library(readr)
library(RSQLite)
# dealscan
package <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/package.xlsx")
facility <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan//facility.xlsx")
lenders <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/lenders.xlsx")
facility_price <- read_excel("~/Google Drive/CodeProjects/PycharmProjects/DealScan/current_facility_pricing.xlsx")

facility <- read_excel("~/CodeProjects/R/RdealScan/facility.xlsx")

p <- package[, c(1,2,3)]
f <- facility[, c(1, 2,3, 7)]
lend <- lenders[, c(1,2,3, 5, 7)]

flend <- merge(f, lend, by="FacilityID")
flendp <- merge(flend, facility_price, by ="FacilityID")
flendp <- flendp[-which(is.na(flendp$BaseRate)),]

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


conn = dbConnect(drv=RSQLite::SQLite(), dbname="~/Google Drive/CodeProjects/PycharmProjects/DealScan/dealscanSQL/dealscanDatabase.db")
relationship <- dbGetQuery(conn, "SELECT * FROM relationship")
testRelationshipTable <- function(borrowerID, lenderID, tableName, checkNum){
  length(table(tableName[which(tableName[,3]==borrowerID & tableName[,5]==lenderID), ][,2])) ==
          checkNum
}
testRelationshipTable(1, 7827, flend, 1)
t <- 0
f <- 0
for(i in 1:nrow(relationship)){
  case <- relationship[i,]
  borId <- as.numeric(case[,1])
  compId <- as.numeric(case[,2])
  numRel <- as.numeric(case[,3])
  if(testRelationshipTable(borId, compId, flendp, numRel) == TRUE){
    t <- t + 1
    cat(sprintf('i=%i\n', i))
  }
  else{
    case <- relationship[i,]
    print(case)
    f <- f + 1
    break 
  }
}
flend[flend$BorrowerCompanyID ==1 & flend$CompanyID == 7827, ]
test <- flendp[which(flendp$BaseRate == "Fixed Rate"), ]
test <- flendp
length(table(test[test$BorrowerCompanyID == 86404 & test$CompanyID == 82462, ]$PackageID))





