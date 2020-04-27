library(readr)
statecovid <- read_csv("CodeProjects/Python/statecovid.csv")
statecovid[,-1]
names<-unlist(statecovid[,1])
x = data.frame(t(statecovid[,-1]))


aggDateWeekly <- function(incompleteIndex, df){
  rows <- dim(df)[1]
  x <- numeric(rows)
  y <- numeric(rows)
  ddf <- dim(df)
  print(ddf[1] - incompleteIndex)
  mults <- floor( (ddf[1]-incompleteIndex)/7)
  counter <- 1
  for( i in 1:(incompleteIndex + mults*7)){
    if(i > incompleteIndex){
      c = i - incompleteIndex 
      x[i] <- counter
      print(c)
      if(c%%7==0){
        counter <- counter + 1
      }
    }
  }
  print(x)
  newdf<-cbind(x,df)
  u <- matrix(0, nrow=counter, ncol= dim(newdf)[2]-1)
  for(j in 1:counter){
    csum <- colSums(newdf[which(newdf[,1] == j), -1])
    u[j,] <- csum
  }
  u
}

WeeklyCovid <- aggDateWeekly(4, x)
WeeklyCovid <- t(WeeklyCovid)
WeeklyCovid <- data.frame(WeeklyCovid)
colnames(WeeklyCovid) <- names
plot(WeeklyCovid[,'AK'], type="l")

JoblessClaims <- read_csv("/home/precision/CodeProjects/Python/JoblessClaims.csv")
colnames(JoblessClaims)[1] <- 'State'


write_csv(WeeklyCovid, '/home/precision/GoogleDrive/Datasets/Covid/weekly_covid.csv')
