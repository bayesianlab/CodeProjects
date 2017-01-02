# obr functions 

getColNumber <- function(df, name){
  return(which(colnames(df)==name))
}

getColNumbers <- function(df, name1, name2){
  return(getColNumber(df, name1):getColNumber(df, name2))
}

naZero <- function(df){
  df[is.na(df)] <- 0
  return(df)
}

getRevenueTotals <- function(revenue){
  totalRev <- data.frame(apply(revenue, 1, sum))
  return(totalRev)
}

unFactorData <- function(df){
  unfactored <- as.data.frame(lapply(df, as.numeric))
  return(unfactored)
}

getOBR <- function(){
  trainingset <- read.csv("~/R/Rprojects/trainingset.csv", header=TRUE)
  colLabels <- c("revenue", "nation", "cruiseLength",
                 "shipName", "age", "sex",
                 "cabinLocation", "loyalty")
  revSlice     <- getColNumber(trainingset, "BAR_REV"):getColNumber(trainingset, "CASINO_REV")
  nationIndx   <- getColNumber(trainingset, "PAX_NATION")
  crLenIndx    <- getColNumber(trainingset, "CRUISELENGTH")
  shipNameIndx <- getColNumber(trainingset, "SHIPNAME")
  ageIndx      <- getColNumber(trainingset, "PAX_AGE")
  gendIndx     <- getColNumber(trainingset, "PAX_GENDER")
  cabinIndx    <- getColNumber(trainingset, "X_META")
  loyaltyIndx  <- getColNumber(trainingset, "PAX_LOYALTY")
  categoricalIndexes <- c(nationIndx, crLenIndx, shipNameIndx, ageIndx, gendIndx, cabinIndx, loyaltyIndx)
  categoricalData <- trainingset[, categoricalIndexes]
  revenue <- trainingset[, revSlice]
  revenue <- naZero(revenue)
  revenue <- getRevenueTotals(revenue)
  obr        <- cbind(revenue, categoricalData)
  obrColumns <- ncol(obr)
  obrRows    <- nrow(obr)
  colnames(obr)[1:obrColumns] <- colLabels
  return(obr)
  
}

getAltOBR <- function(obr){
  spendingPerDay <- data.frame(obr[,"revenue"]/obr[,"cruiseLength"])
  altobr <- obr
  altobr[,1] <- spendingPerDay
  colnames(altobr)[1] <- "spendPerDay"
  return(altobr)
}

calcTuners <- function(guessMeanInvGamma){
  alpha0 <- 6
  del0 <- (guessMeanInvGamma*(2)) *2
  return(del0)
}

loyaltyAndSpendingLine <- function(altobr){
  spendByLoyalty <- aggregate(spendPerDay~loyalty, altobr, mean)
  colnames(spendByLoyalty)[2] <- "avgSpend"
  x <- 1:nlevels(altobr$loyalty)
  ests <- coef(lm(avgSpend ~ x, data=spendByLoyalty))
  
  p <- ggplot(spendByLoyalty, aes(loyalty, avgSpend))
  p + geom_point() + geom_abline(intercept=ests[
    
  ], slope=ests[2], color="blue" )
}

loyaltyAndSpendingBox <- function(altobr){
  plot <- ggplot(altobr, aes(loyalty, spendPerDay))
  plot+geom_boxplot(aes(colour=loyalty)) + geom_jitter(width=.1, aes(colour=loyalty))
}

ageAndSpending <- function(altobr){
  spendByAge <- aggregate(spendPerDay~age, altobr, mean)
  plot <- ggplot(altobr, aes(age, spendPerDay))
  plot + geom_jitter(aes(colour=age))
}

sexAndSpendingBar <- function(altobr){
  spendBySex <- aggregate(spendPerDay~sex, altobr, sum)
  plot <- ggplot(spendBySex, aes(sex))
  plot + geom_bar(aes( weight=spendPerDay, fill=sex), width=.5)
}

sexAndSpendingBox <- function(altobr){
  p3 <- ggplot(altobr, aes(sex, spendPerDay))
  p3 + geom_boxplot(aes(colour=sex), width=.5) 
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
