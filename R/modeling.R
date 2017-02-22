# modeling
library(coda)
library(dummies)
library(rjags)

# Women .8607...
# women 2, men 1
# nonblack -.31...

# example
# set.seed(123)
# beta.0 <- 0
# sigma.sq <- 1
# n <- 1500
# y <- rnorm(n, beta.0, sigma.sq)
# data <- list(y=y,n=n)
# inits <- list(beta.0=0, sigma.sq=1)
# jags_m <- jags.model(file="~/Google Drive/CodeProjects/R/x1.bug", data=data, inits=inits, n.chains=1, n.adapt = 100)
# cs <- coda.samples(jags_m, c('beta.0', 'sigma.sq'), n.iter = 1000)
# plot(cs)
# summary(cs)


allData <- readRDS('~/Google Drive/CodeProjects/R/allData.rds')
# allData <- allData[sample(1:nrow(allData), 1000), ]
time <- -27:26
timeAndIndex <- as.data.frame(cbind(1:54, time))
allData <-merge(allData, timeAndIndex, by="time")
colnames(allData)[10] <- 'timeIndex'
allData <- allData[,c('question', 'race', 'gender', 'age', 'educ', 'region', 'time', 'state', 'legality', 'timeIndex')]
N <- nrow(allData)
y <- allData$question 
y <- as.numeric(as.character(y)) - 1
x <- allData$region
g <- allData$gender
dataTime <- as.data.frame(allData[, c('time', 'timeIndex')])
state <- allData$state
state <- factor(state)
levels(state)
levels(state) <- c(1:51)
state <- as.numeric(as.character(state))
region <- regionKeys$region

r <- allData$region
age <- allData$age
levels(age) <- c(1:4)
age  <- as.numeric(as.character(age))
educ  <- allData$educ
g <- allData$gender
g <- as.data.frame(cbind(1:length(g), g))
colnames(g)[1] <- 'id'
g$g <- factor(g$g)
levels(g$g)
genderDex <- rbind(cbind(which(g[,2] == "-1.16172173588625"), rep(1, length(which(g[,2] == "-1.16172173588625")))), 
cbind(which(g[,2] != "-1.16172173588625"), rep(2, length(which(g[,2] != "-1.16172173588625")))))
colnames(genderDex) <- c('id', 'val')
g <- merge(g, genderDex, by='id')

race <- allData$race
id <- 1:length(race)
race <- as.data.frame(cbind(id, allData$race))
race$V2 <- factor(race$V2)
levels(race$V2)
raceDex <- rbind(cbind(which(race[,2] =="-0.31276992801118"), rep(1, length(which(race[,2]=="-0.31276992801118")))), 
            cbind(which(race[,2]!="-0.31276992801118"), rep(2, length(which(race[,2]!="-0.31276992801118")))))
colnames(raceDex) <-  c('id', 'val')
race <- merge(race, raceDex, by ='id')
race$V2 <- as.numeric(as.character(race$V2))
g$g <-  as.numeric(as.character(g$g))

jagsVars <- list('N'=N, 'y'= y, 'dataTime'=dataTime, 'race'=race, 'g'=g, 'age'=age, 'rData'=r, 'ed'=educ, 'state'= state, 
                 'region'=region, 'xState'=xState, 'timeAndIndex'=timeAndIndex, 'zState'=zState)
js <- jags.model('~/Google Drive/CodeProjects/R/logit.bug', data=jagsVars, n.chains = 3, n.adapt=10000)
# js <- readRDS('~/Google Drive/CodeProjects/R/js.rds')
cs <- coda.samples(js, c('alphaYear', 'nationalMu', 'muDelta', 'phi'), n.iter=10000, n.burnin=5000 thin=5)

summary(cs)
# means <- summary(cs)
# frame <- as.data.frame(means[[1]])
# frame <- as.data.frame(cbind(row.names(frame), frame))
# write_csv(frame, "~/Desktop/deltaBlackFemaleState.csv")
# plot(cs)
# gelman.diag(cs)
# gelman.plot(cs)
 
