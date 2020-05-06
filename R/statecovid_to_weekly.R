#!/usr/bin/env Rscript
library(readr)
statecovid <- read_csv("/home/precision/CodeProjects/Python/statecovid.csv")
statecovid[,-1]
names<-unlist(statecovid[,1])
x = data.frame(t(statecovid[,-1]))


aggDateWeekly <- function(incompleteIndex, startDate, df){
  rows <- dim(df)[1]
  x <- numeric(rows)
  y <- numeric(rows)
  ddf <- dim(df)
  mults <- floor( (ddf[1]-incompleteIndex)/7)
  print(paste("Number of weeks=", mults) )
  counter <- 1
  for( i in 1:(incompleteIndex + mults*7)){
    if(i > incompleteIndex){
      c = i - incompleteIndex 
      x[i] <- counter
      if(c%%7==0){
        counter <- counter + 1
      }
    }
  }
  Dates = seq.Date(from=as.Date(startDate), length.out=mults, by='week')
  newdf<-cbind(x,df)
  u <- data.frame(matrix(0, nrow=mults, ncol= dim(newdf)[2]-1))
  for(j in 1:mults){
    csum <- colSums(newdf[which(newdf[,1] == j), -1])
    u[j,] <- csum
  }
  u <- data.frame(t(u))
  colnames(u) <- as.Date(Dates)
  t(u)
}

WeeklyCovid <- as.data.frame(t(aggDateWeekly(4, "2020-01-25", x)))

rownames(WeeklyCovid) <- statecovid$State
JoblessClaims <- read.csv("/home/precision/CodeProjects/Python/JoblessClaims.csv",header=TRUE, row.names = 1)
WeeklyCovid <- WeeklyCovid[, 1:(dim(JoblessClaims)[2])]

CovidData <- data.frame(matrix(0, nrow=dim(JoblessClaims)[1]*2, ncol=dim(JoblessClaims)[2]))
s <- 1:2
v <- rep(1, dim(JoblessClaims)[1])
v[1] <-0
for(j in 1:dim(JoblessClaims)[1][[1]]){
  s <- s + v[j]*2
  rows <- rbind(as.numeric(JoblessClaims[j,]), as.numeric(WeeklyCovid[j,]))
  CovidData[s,] <- rows
}

state_codes <- read_csv("/home/precision/GoogleDrive/Datasets/Covid/states_codes.csv")
state_pop <- read_csv("/home/precision/GoogleDrive/Datasets/Covid/state_pop.csv")
state_pop <- state_pop[which(state_pop$STATE > 0), c('NAME', 'POPESTIMATE2019')]
state_pop <- state_pop[order(state_codes$Abbreviation),]
CovidData<- CovidData/kronecker(state_pop$POPESTIMATE2019/100, c(1,1))

write_csv(CovidData, '/home/precision/GoogleDrive/Datasets/Covid/CovidData.csv', col_names = FALSE)
write_csv(CovidData, '/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/CovidData.csv', col_names=FALSE)