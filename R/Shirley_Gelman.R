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


menWomenInFavor <- as.data.frame(matrix(0, nrow = length(allData), ncol = 7))
for(i in 1:length(allData)){
  menWomenInFavor[i, 1] <- dfNames[i]
  frame <- subset(allData[[i]], select=c('gender', 'question'))
  menWomenInFavor[i, 2] <- table(frame$gender == 1 & frame$question == 1)["TRUE"]
  menWomenInFavor[i, 3] <- table(frame$gender == 1 & frame$question == 2)["TRUE"]
  menWomenInFavor[i, 4] <- table(frame$gender == 0 & frame$question == 1)["TRUE"]
  menWomenInFavor[i, 5] <- table(frame$gender == 0 & frame$question == 2)["TRUE"]
  menWomenInFavor[i, 6] <- menWomenInFavor[i, 2] / (menWomenInFavor[i, 2] + menWomenInFavor[i, 3])
  menWomenInFavor[i, 7] <- menWomenInFavor[i, 4] / (menWomenInFavor[i, 4] + menWomenInFavor[i, 5])
  colnames(menWomenInFavor) <- c("date", "f favor", "f no", "m favor", "m no", "f p", "m p")
}
proportionFavor <- as.data.frame(matrix(0, nrow=1, ncol=12))
mfSupport <- apply(menWomenInFavor[2:5], 2, sum)
proportionFavor[1,1] <-  mfSupport[1] / (mfSupport[1] + mfSupport[2])
proportionFavor[1, 2] <- mfSupport[3] / (mfSupport[3] + mfSupport[4])

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
blackSupport
proportionFavor[1,3] <- blackSupport[1] / (blackSupport[1] + blackSupport[2])
proportionFavor[1,4] <- blackSupport[3] / (blackSupport[3] + blackSupport[4])


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
proportionFavor[1, 5] <- ageSupport[1] / (ageSupport[1] + ageSupport[2])
proportionFavor[1, 6] <- ageSupport[3] / (ageSupport[3] + ageSupport[4])
proportionFavor[1, 7] <- ageSupport[5] / (ageSupport[5] + ageSupport[6])
proportionFavor[1, 8] <- ageSupport[7] / (ageSupport[7] + ageSupport[8])


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
educSupport
proportionFavor[1, 9] <- educSupport[1] / (educSupport[1]+educSupport[2])
proportionFavor[1, 10] <- educSupport[3] / (educSupport[3]+educSupport[4])
proportionFavor[1, 11] <- educSupport[5] / (educSupport[5]+educSupport[6])
proportionFavor[1, 12] <- educSupport[7] / (educSupport[7]+educSupport[8])

proportionFavor <- t(proportionFavor)
proportionFavor <- as.data.frame(cbind( c("Women", "Men", "Black", 'Non-black', '18-29', '30-44', 
         '45-64', '65 +', 'Less than High School', 'High School', 'Less than College',
         'College or more'), proportionFavor))
# colnames(proportionFavor) <- c("women", "men", "black", 'nonblack', '18-29', '30-44', 
#                                '45-64', '65 +', '<HS', 'HS', '<C', 'C+')
proportionFavor$V1 <- factor(proportionFavor$V1, 
                             levels=rev(unique(as.character(proportionFavor$V1))))
proportionFavor$V2 <- round(as.numeric(as.character(proportionFavor$V2)),2)


ggplot() + geom_point(data=proportionFavor, aes(x=V2, y=V1))



