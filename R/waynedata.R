waynedata <- read_excel("~/Downloads/963-972 (raw) (sorted by ID and INC_RANK).xlsx")
rows_cols = dim(waynedata)
stopgrabbingrows <- 5
isfirstperiod <- 1
rowcount <- 1
newdf <- as.data.frame(matrix(nrow=rows_cols[1], ncol=rows_cols[2], 0))
for(i in 1:rows_cols[1]){
  if( (waynedata$INC_RANK[i] == '.') && (isfirstperiod == 1)){
    stopgrabbingrows = 1
    isfirstperiod = 0
  }
  if(stopgrabbingrows == 5){
    newdf[rowcount, ] <- waynedata[i,]
    rowcount <- rowcount + 1
    isfirstperiod <- 1
  }
  else if(stopgrabbingrows <= 4){
    stopgrabbingrows = stopgrabbingrows + 1
    if(stopgrabbingrows == 5){
      isfirstperiod <- 1
    }
  }
}
colnames(newdf) = colnames(waynedata)
newdf = newdf[1:rowcount, ]