
as.integer(finaldat$INCOME)[1:20]
cd <- subset(finaldat, select=c(onBoardDailySpend, NTR, TRADE, CRUISELENGTH, PAX_AGE, PAX_GENDER, 
                          NATIONALITY, X_META, PAX_LOYALTY, INCOME))

td <- mice(cd,m=1,maxit=1,meth='pmm',seed=500)
fnames <- levels(finaldat$INCOME)
s <- complete(td,1)
s$INCOME <- factor(s$INCOME)
s$INCOME <- mapvalues(s$INCOME, from =c("1", "2", "3", "4", "5", "6", "7", "8"), to = c("Under 20000",  "20000-29999",   "30000-49999",   
                                              "50000-69999","70000-99999", "100000-124999", 
                                              "125000-250000", "Over 250000"))



