path = "~/Google Drive/CodeProjects/R/"
source(paste(path, "cleanData.R", sep=""))

allData <- list(nov1_1953, march29_1956, august29_1957, march2_1960, jan7_1965, may19_1966, june2_1967, 
            jan23_1969, oct29_1971, march3_1972, nov10_1972, april19_1976, march3_1978, jan30_1981, 
            jan11_1985, jan10_1986, june13_1991, sept6_1994, may11_1995, feb8_1999, feb14_2000,
            feb19_2001, may19_2003, may5_2006)

dfNames <- c('nov1_1953', 'march29_1956', 'august29_1957', 'march2_1960', 'jan7_1965', 'may19_1966',
             'june2_1967', 'jan23_1969', 'oct29_1971', 'march3_1972', 'nov10_1972', 'april19_1976',
             'march3_1978', 'jan30_1981', 'jan11_1985', 'jan10_1986', 'june13_1991', 'sept6_1994',
             'may11_1995', 'feb8_1999', 'feb14_2000', 'feb19_2001', 'may19_2003', 'may5_2006')

inFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 7))
for(i in 1:length(allData)){
  frame <- as.data.frame(allData[i])$question
  inFavor[i, 1] <- dfNames[i]
  inFavor[i, 2] <- table(frame == 1)['TRUE']
  inFavor[i, 3] <- table(frame == 2)['TRUE']
  n <- table(frame == 1)['TRUE'] + table(frame == 2)['TRUE']
  inFavor[i, 4] <- inFavor[i, 2] / (inFavor[i,2] + inFavor[i,3])
  inFavor[i, 5] <- sqrt((inFavor[i, 4]* (1 - inFavor[i, 4])) * 1/n)
  inFavor[i, 6] <- inFavor[i, 4] + inFavor[i,5]*qnorm(.95, 0, 1)
  inFavor[i, 7] <- inFavor[i, 4] - inFavor[i,5]*qnorm(.95, 0, 1)
}

inFavor$V1 <- factor(inFavor$V1, levels=unique(as.character(inFavor$V1)))

dates <- as.Date(c("1953/11/1", '1956/3/1', "1957/8/1", "1960/3/1", "1965/1/1", "1966/5/1", 
          "1967/6/1", "1969/1/1", "1971/10/1", "1972/3/1", "1972/11/1", "1976/4/1", "1978/3/1",
          "1981/1/1", "1985/1/1", "1986/1/1", "1991/6/1", "1994/9/1", "1995/5/1", "1999/2/1", 
          '2000/2/1', "2001/2/1", "2003/5/1", "2006/5/1"))
inFavor <- cbind(dates, inFavor)
colnames(inFavor) <- c("Date", "name", "Favor", "Oppose", "ProportionFavor", "SD", "Upper", "Lower")
timeSpan <- as.data.frame(seq(as.Date("1953/11/01"), to=as.Date("2006/5/1"), by = "month"))
id <- 1:nrow(timeSpan)

timeSpan <- cbind(id, timeSpan)
colnames(timeSpan) <- c("id", "Date")
c <- 1
ids <- as.data.frame(matrix(0, nrow = nrow(inFavor), ncol=1))
for(i in 1:nrow(timeSpan)){
  if(as.character(timeSpan$Date[i]) == as.character(inFavor$Date[c])){
    ids[c, 1] <- i
    c <- c + 1
  }
}
inFavor <- cbind(ids, inFavor)
colnames(inFavor)[1] <- "id"
replace(timeSpan,which(is.na(x)),0)
timeSpan <- merge(timeSpan, inFavor, by ="id", all.x=TRUE)
lims <- aes(ymax=timeSpan$Upper, ymin = timeSpan$Lower)

# proportion support plot 
ggplot(timeSpan, aes(x=Date.x, y =ProportionFavor)) + geom_pointrange(lims)+
  theme(panel.background=element_rect(fill='white'), axis.text = element_text(size= 20),
        panel.border = element_rect(fill=NA) ) + xlab('Year') + 
  ylab('Proportion Support') + ylim(.4, .9)

summary(inFavor$ProportionFavor)

menWomenInFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 13))
for(i in 1:length(allData)){
  menWomenInFavor[i, 1] <- dfNames[i]
  frame <- subset(allData[[i]], select=c('gender', 'question'))
  menWomenInFavor[i, 2] <- table(frame$gender == 1 & frame$question == 1)["TRUE"]
  menWomenInFavor[i, 3] <- table(frame$gender == 1 & frame$question == 2)["TRUE"]
  menWomenInFavor[i, 4] <- table(frame$gender == 0 & frame$question == 1)["TRUE"]
  menWomenInFavor[i, 5] <- table(frame$gender == 0 & frame$question == 2)["TRUE"]
  menWomenInFavor[i, 6] <- menWomenInFavor[i, 2] / (menWomenInFavor[i, 2] + menWomenInFavor[i, 3])
  menWomenInFavor[i, 7] <- menWomenInFavor[i, 4] / (menWomenInFavor[i, 4] + menWomenInFavor[i, 5])
  women <- table(frame$gender == 1)["TRUE"]
  men <- table(frame$gender == 0)["TRUE"]
  menWomenInFavor[i, 8] <- sqrt(menWomenInFavor[i, 6] * (1 - menWomenInFavor[i,6]) * 1/women)
  menWomenInFavor[i, 9] <- menWomenInFavor[i, 6] + menWomenInFavor[i, 8]*qnorm(.95, 0 , 1)
  menWomenInFavor[i, 10] <- menWomenInFavor[i, 6] - menWomenInFavor[i, 8]*qnorm(.95, 0 , 1)
  menWomenInFavor[i, 11] <- sqrt(menWomenInFavor[i, 7] * (1 - menWomenInFavor[i,7]) * 1/men)
  menWomenInFavor[i, 12] <- menWomenInFavor[i, 7] + menWomenInFavor[i, 11]*qnorm(.95, 0 , 1)
  menWomenInFavor[i, 13] <- menWomenInFavor[i, 7] - menWomenInFavor[i, 11]*qnorm(.95, 0 , 1)
  colnames(menWomenInFavor) <- c("date", "fFavor", "fNo", "mFavor", "mNo", "fp", "mp", "sdw",
                                 "upw", "loww", "sdm", "upm", "lowm")
}
proportionFavor <- as.data.frame(matrix(0, nrow=3, ncol=12))
mfSupport <- apply(menWomenInFavor[2:5], 2, sum)
women <- (mfSupport[1] + mfSupport[2])
men <-  (mfSupport[3] + mfSupport[4])
proportionFavor[1,1] <-  mfSupport[1] / women
proportionFavor[1, 2] <- mfSupport[3] / men
proportionFavor[2,1] <- proportionFavor[1,1] + 
  qnorm(.975, 0, 1)*sqrt(proportionFavor[1,1] * (1 - proportionFavor[1,1]) *(1/women))
proportionFavor[3,1] <- proportionFavor[1,1] - 
  qnorm(.975, 0, 1)*sqrt(proportionFavor[1,1] * (1 - proportionFavor[1,1]) *(1/women))
proportionFavor[2,2] <- proportionFavor[1,2] + 
  qnorm(.975, 0, 1)*sqrt(proportionFavor[1,2] * (1 - proportionFavor[1,2]) *(1/men))
proportionFavor[3,2] <- proportionFavor[1,2] - 
  qnorm(.975, 0, 1)*sqrt(proportionFavor[1,2] *(1 - proportionFavor[1,2]) *(1/men))

blacksInFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 7))
for(i in 1:length(allData)){
  blacksInFavor[i, 1] <- dfNames[i]
  frame <- subset(allData[[i]], select=c('race', 'question'))
  blacksInFavor[i, 2] <- table(frame$race == 1 & frame$question == 1)['TRUE']
  blacksInFavor[i, 3] <- table(frame$race == 1 & frame$question == 2)['TRUE']
  blacksInFavor[i, 4] <- table(frame$race == 0 & frame$question == 1)['TRUE']
  blacksInFavor[i, 5] <- table(frame$race == 0 & frame$question == 2)['TRUE']
}

blackSupport <- apply(blacksInFavor[2:5], 2, sum)
blacks <- blackSupport[1] + blackSupport[2]
nonBlacks <- (blackSupport[3] + blackSupport[4])
proportionFavor[1,3] <- blackSupport[1] / blacks
proportionFavor[1,4] <- blackSupport[3] / nonBlacks
proportionFavor[2,3] <- proportionFavor[1,3] +
  qnorm(.95, 0, 1)*sqrt(proportionFavor[1,3] * (1 - proportionFavor[1,3]) *(1/blacks))
proportionFavor[3,3] <- proportionFavor[1,3] - qnorm(.95, 0, 1)*sqrt(proportionFavor[1,3] * 
                                                                       (1 - proportionFavor[1,3]) *(1/blacks))
proportionFavor[2,4] <- proportionFavor[1,4] + qnorm(.95, 0, 1)*sqrt(proportionFavor[1,4] * 
                                                                       (1 - proportionFavor[1,4]) *(1/nonBlacks))
proportionFavor[3,4] <- proportionFavor[1,4] - qnorm(.95, 0, 1)*sqrt(proportionFavor[1,4] * 
                                                                       (1 - proportionFavor[1,4]) *(1/nonBlacks))
ageFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 9))
for(i in 1:length(allData)){
  ageFavor[i, 1] <- dfNames[i]
  frame <- subset(allData[[i]], select=c('age', 'question'))
  ageFavor[i ,2] <- table(frame$age == 0 & frame$question == 1)['TRUE']
  ageFavor[i ,3] <- table(frame$age == 0 & frame$question == 2)['TRUE']
  ageFavor[i ,4] <- table(frame$age == 1 & frame$question == 1)['TRUE']
  ageFavor[i ,5] <- table(frame$age == 1 & frame$question == 2)['TRUE']
  ageFavor[i ,6] <- table(frame$age == 2 & frame$question == 1)['TRUE']
  ageFavor[i ,7] <- table(frame$age == 2 & frame$question == 2)['TRUE']
  ageFavor[i ,8] <- table(frame$age == 3 & frame$question == 1)['TRUE']
  ageFavor[i ,9] <- table(frame$age == 3 & frame$question == 2)['TRUE']
}
ageSupport <- apply(ageFavor[2:9], 2, sum)
young <- (ageSupport[1] + ageSupport[2])
workingAge <- (ageSupport[3] + ageSupport[4])
mature <- (ageSupport[5] + ageSupport[6])
old <- (ageSupport[7] + ageSupport[8])
proportionFavor[1, 5] <- ageSupport[1] / young 
proportionFavor[1, 6] <- ageSupport[3] / workingAge
proportionFavor[1, 7] <- ageSupport[5] / mature
proportionFavor[1, 8] <- ageSupport[7] / old

proportionFavor[2, 5] <- proportionFavor[1, 5] + 
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,5]*(1 - proportionFavor[1,5])*(1/young))
proportionFavor[3, 5] <- proportionFavor[1, 5] - 
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,5]*(1 - proportionFavor[1,5])*(1/young))
proportionFavor[2, 6] <- proportionFavor[1, 6] + 
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,6]*(1 - proportionFavor[1,6])*(1/workingAge))
proportionFavor[3, 6] <- proportionFavor[1, 6] -
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,6]*(1 - proportionFavor[1,6])*(1/workingAge))
proportionFavor[2, 7] <- proportionFavor[1, 7] +
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,7]*(1 - proportionFavor[1,7])*(1/mature))
proportionFavor[3, 7] <- proportionFavor[1, 7] -
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,7]*(1 - proportionFavor[1,7])*(1/mature))
proportionFavor[2, 8] <- proportionFavor[1, 8] +
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,8]*(1 - proportionFavor[1,8])*(1/old))
proportionFavor[3, 8] <- proportionFavor[1, 8] - 
  qnorm(.95,0, 1) * sqrt(proportionFavor[1,8]*(1 - proportionFavor[1,8])*(1/old))



educFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 9))
for(i in 1:length(allData)){

  educFavor[i, 1] <- dfNames[i]
  frame <- subset(allData[[i]], select=c('educ', 'question'))
  educFavor[i, 2] <- table(frame$educ == 0 & frame$question == 1)['TRUE']
  educFavor[i,3] <- table(frame$educ == 0 & frame$question == 2)['TRUE']
  educFavor[i, 4] <- table(frame$educ == 1 & frame$question == 1)['TRUE']
  educFavor[i, 5] <- table(frame$educ == 1 & frame$question == 2)['TRUE']
  educFavor[i, 6] <- table(frame$educ == 2 & frame$question == 1)['TRUE']
  educFavor[i, 7] <- table(frame$educ == 2 & frame$question == 2)['TRUE']
  educFavor[i, 8] <- table(frame$educ == 3 & frame$question == 1)['TRUE']
  educFavor[i,9] <- table(frame$educ == 3 & frame$question == 2)['TRUE']
}
educSupport <- apply(educFavor[,2:9], 2, sum)
noSchool <- educSupport[1]+educSupport[2]
highSchool <- educSupport[3]+educSupport[4]
noDegree <- educSupport[5]+educSupport[6]
degree <- educSupport[7]+educSupport[8]
proportionFavor[1, 9] <- educSupport[1] / noSchool
proportionFavor[1, 10] <- educSupport[3] / highSchool
proportionFavor[1, 11] <- educSupport[5] / noDegree
proportionFavor[1, 12] <- educSupport[7] / degree

proportionFavor[2, 9] <- proportionFavor[1, 9] + qnorm(.95,0, 1) *sqrt(proportionFavor[1, 9]*(1 - proportionFavor[1, 9]) * (1/noSchool))
proportionFavor[3, 9] <- proportionFavor[1, 9] - qnorm(.95,0, 1) *sqrt(proportionFavor[1, 9]*(1 - proportionFavor[1, 9]) * (1/noSchool))
proportionFavor[2, 10] <- proportionFavor[1, 10] + qnorm(.95, 0, 1) *sqrt(proportionFavor[1, 10]*(1 - proportionFavor[1, 10]) * (1/highSchool))
proportionFavor[3, 10] <- proportionFavor[1, 10] - qnorm(.95, 0, 1) *sqrt(proportionFavor[1, 10]*(1 - proportionFavor[1, 10]) * (1/highSchool))
proportionFavor[2, 11] <- proportionFavor[1, 11] + qnorm(.95,0, 1) *sqrt(proportionFavor[1, 11]*(1 - proportionFavor[1, 11]) * (1/noDegree))
proportionFavor[3, 11] <- proportionFavor[1, 11] - qnorm(.95,0, 1) *sqrt(proportionFavor[1, 11]*(1 - proportionFavor[1, 11]) * (1/noDegree))
proportionFavor[2, 12] <- proportionFavor[1, 12] + qnorm(.95,0, 1) *sqrt(proportionFavor[1, 12]*(1 - proportionFavor[1, 12]) * (1/degree))
proportionFavor[3, 12] <- proportionFavor[1, 12] - qnorm(.95,0, 1) *sqrt(proportionFavor[1, 12]*(1 - proportionFavor[1, 12]) * (1/degree))

proportionFavor <- t(proportionFavor)

# There is a reason for doing this!
proportionFavor <- as.data.frame(cbind(c("Women", "Men", "Black", 'Non-black', '18-29', '30-44', 
                               '45-64', '65 +', 'Less than High School', 'High School', 'Less than College',
                               'College or more'), proportionFavor))
# Men first
proportionFavor <- proportionFavor[c(2,1,3,4,5,6,7,8,9,10,11,12), ]
proportionFavor$V1 <- factor(proportionFavor$V1, 
                             levels=rev(unique(as.character(proportionFavor$V1))))

colnames(proportionFavor) <- c("breaks", "favor", "upB", "lowB")
proportionFavor$upB <- as.numeric(as.character(proportionFavor$upB))
proportionFavor$lowB <- as.numeric(as.character(proportionFavor$lowB))
proportionFavor$favor <- as.numeric(as.character(proportionFavor$favor))
lims <- aes(ymax=upB, ymin = lowB)
ggplot(data=proportionFavor, aes(x=breaks, y = favor)) +  geom_pointrange(lims) + 
  theme(panel.background=element_rect(fill='white'), axis.text = element_text(size= 20),
        panel.border = element_rect(fill=NA) ) +
  ylab("Proportion Favor Death Penalty") + xlab('') + coord_flip()



