path <- '~/Google Drive/CodeProjects/R/'
allData <- readRDS('~/Google Drive/CodeProjects/R/allData.rds')
source(paste(path, 'cleanData.R', sep=''))
library(gdata)
keep(xState, zState, allData, regionKeys, path, sure=TRUE)
time <- -27:26
timeAndIndex <- as.data.frame(cbind(1:54, time))
allData <- merge(allData, timeAndIndex, by="time")
colnames(allData)[10] <- 'timeIndex'
allData <- allData[,c('question', 'race', 'gender', 'age', 'educ', 'region', 'time', 'state', 'legality', 'timeIndex')]
dataTime <- as.data.frame(allData[, c('time', 'timeIndex')])
state <- allData$state
state <- factor(state)
# rewriting state to have levels 1-51 for bugs
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

N <- nrow(allData)
y <- as.numeric(as.character(allData$question)) - 1
g <- allData$gender
