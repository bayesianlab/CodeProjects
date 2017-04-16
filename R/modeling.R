# modeling
# Women .8607...
# women 2, men 1
# nonblack -.31...
# 0 means favor for question!
library(coda)
library(dummies)
library(rjags)
# keep(xState, zState, allData, regionKeys, sure=TRUE)
path = '~/Google Drive/CodeProjects/R/'
source(paste(path, 'prepForJags.R', sep=''))
keep(N,y, dataTime, race, g, age, r, educ, state, region, xState, timeAndIndex, zState, allData, path, sure=TRUE)
# allData <- allData[sample(1:nrow(allData), 1000), ]

# Careful!! Dont uncomment this!
jagsVars <- list('N'=N, 'y'= y, 'dataTime'=dataTime, 'race'=race, 'g'=g, 'age'=age, 'rData'=r, 'ed'=educ, 'state'= state,
                 'region'=region, 'xState'=xState, 'timeAndIndex'=timeAndIndex, 'zState'=zState)
# js <- jags.model('~/Google Drive/CodeProjects/R/logit.bug', data=jagsVars, n.chains = 3, n.adapt=10000)

# cs <- coda.samples(js, c('alphaStateYear', 'nationalMu', 'muDelta', 'phi'), n.iter=5000, n.burnin=5000, thin=5)

pis <- readRDS('~/Google Drive/CodeProjects/R/pis.rds')
pis <- as.data.frame(cbind(y, allData$time, pis))
colnames(pis)[1:2] <- c('question', 'time')

# Fitted actual
pistimes <- factor(pis$time)
levs <- levels(pistimes)
inFavFit <- as.data.frame(matrix(0, nrow=length(levs), ncol=2))
for(i in 1:length(levs)){
  fits <- pis[pis[,2] == levs[i],c(1,3)]
  inFavFit[i, 1:2] <- 1-apply(fits, 2, mean)
}

dates <- as.Date(c("1953/11/1", '1956/3/1', "1957/8/1", "1960/3/1", "1965/1/1", "1966/5/1", 
                   "1967/6/1", "1969/1/1", "1971/10/1", "1972/3/1", "1972/11/1", "1976/4/1", "1978/3/1",
                   "1981/1/1", "1985/1/1", "1986/1/1", "1991/6/1", "1994/9/1", "1995/5/1", "1999/2/1", 
                   '2000/2/1', "2001/2/1", "2003/5/1", "2006/5/1"))

dates <- dates[-which(dates=="1972/3/1")]
inFavFit <- cbind(dates, inFavFit)
colnames(inFavFit) <- c("Date", "favorActual", 'favorEst')
tSpan <- as.data.frame(seq(as.Date("1953/11/01"), to=as.Date("2006/5/1"), by = "month"))
id <- 1:nrow(tSpan)
tSpan <- cbind(id, tSpan)
colnames(tSpan) <- c("id", "Date")
c <- 1
ids <- as.data.frame(matrix(0, nrow = nrow(inFavFit), ncol=1))
for(i in 1:nrow(tSpan)){
  if(as.character(tSpan$Date[i]) == as.character(inFavFit$Date[c])){
    ids[c, 1] <- i
    c <- c + 1
  }
}
inFavFit <- cbind(ids, inFavFit)
colnames(inFavFit)[1] <- "id"
tSpan <- merge(tSpan, inFavFit, by ="id", all.x=TRUE)

# proportion support plot 
g <- ggplot(tSpan, aes(x=Date.x)) + theme(panel.background=element_rect(fill='white'), axis.text = element_text(size= 20),
                                          panel.border = element_rect(fill=NA) )
g + geom_point(shape=5,aes(y=favorActual))  + geom_jitter(aes(y=favorEst), shape=20, color='red') + xlab('Time') + ylab('Proportion in favor')


# cs3 <- readRDS('~/Google Drive/CodeProjects/R/cs3.rds')
# js <- readRDS('~/Google Drive/CodeProjects/R/js.rds')

length(readLines(paste(path, 'prepForJags.R', sep=''))) +
length(readLines(paste(path, 'modeling.R', sep=''))) +
length(readLines(paste(path, 'Shirley_Gelman.R', sep=''))) +
length(readLines(paste(path, 'cleanData.R', sep=''))) + 165 + 211 + 100

(51*54) + (4*51) + (4*51) + (4*51) + (2*51) + (2*51) + (2*51) + (2*51) + (8*51) + (8*51)
