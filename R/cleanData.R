# clean data
# Shirley and Gelman paper
# 1 Female, 0 Male
# Educ 0, 1, 2, 3; <HS, HS grad, <College Grad, College Grad< 
# Age 0, 1, 2, 3; 18-29, 30-44, 45-64, 65< 

library(foreign)
library(readr)
library(plyr)
library(ggplot2)
library(rockchalk)
library(dplyr)
library(matrixStats)
library(gdata)

handleNas <- function(df, questionNum)
{
  {
    if(dim(table(is.na(df[,questionNum]))) == 1)
    {
      df
    }
    else
    {
      df <- df[-which(is.na(df[,questionNum])), ]
      df
    }
  }
}

handle3s <- function(df, questionNum)
{
  if(dim(table(df[,questionNum] == 3)) == 1)
  {
    df
  }
  else
  {
    df <- df[-which(df[, questionNum] == 3), ]
  }
}

handle4s <- function(df, questionNum)
{
  if(dim(table(df[,questionNum] == 4)) == 1)
  {
    df
  }
  else
  {
    df <- df[-which(df[, questionNum] == 4), ]
  }
}


cleanData <- function(df, questionNum)
{
  df <- handleNas(df,questionNum)
  df <- handle3s(df, questionNum)
  df <- handle4s(df, questionNum)
}
orderAndCleanData <- function(df, questionNum)
{
  dfCopy <- df
  dfCopy <- cleanData(dfCopy, questionNum)
  dfCopy <- select(dfCopy, question, race, gender, age, educ, state, time)
  return(dfCopy)
}

cutAges <- function(df, ageNum){
  df <- df[df[,ageNum] >= 18, ]
  y  <- cut(df[,ageNum], c(18,29, 44, 64, 150), labels= c(0,1,2,3))
  df[, ageNum] <- y
  colnames(df)[ageNum] <- "age"
  df
}

handleGenderRaceCol <- function(df, grCol, maleNums, blackNums){
  print(grCol)
  x <- combineLevels(df[,grCol], levs = maleNums, newLabel="F")
  df <- cbind(df, 1*(x == "F"))
  y <- combineLevels(df[, grCol], levs = blackNums, newLabel ="Black")
  df <- cbind(df, 1*(y=="Black"))
  rc <- dim(df)
  colnames(df)[(rc[2]-1):rc[2]] <- c("gender", "race")
  df <- df[, -grCol]
  df
}

fixData <- function(df, ageNum, grCol, maleNums, blackNums){
  df <- cutAges(df, ageNum)
  df <- handleGenderRaceCol(df, grCol, maleNums, blackNums)
}

bindDate <- function(df, year){
  t1 <- -27:26
  t2 <- 1953:2006
  dateSeq <- as.data.frame(cbind(t1, t2))
  df <- cbind(df, rep(dateSeq[dateSeq[,2]==year,1], nrow(df)))
  colnames(df)[ncol(df)] <- 'time'
  df
}
usStates <- read_csv("~/Google Drive/CodeProjects/R/us_states.csv")
colnames(usStates) <- c('s', 'c', 'state', 'legality')
usStates <- usStates[,3:4]
usStates <- usStates[-52,]
dataFiles <- "/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/GelmanPaper/"
may19_2003 <- read.spss(paste(dataFiles, 'may19_2003.por', sep =''), to.data.frame = TRUE)

may19_2003 <- subset(may19_2003, select = c( WTFCTR, RACE, STATE, D3, D2, S3, Q13 ))
may5_2006 <- read.csv(paste(dataFiles, 'may5_2006.csv', sep =''))
colnames(may19_2003) <- c('weights', 'race', 'state', 'educ', 'age', 'gender', 'question')
april19_1976 <- read.csv(paste(dataFiles, 'april19_1976.csv', sep =''))
august29_1957 <- read.csv(paste(dataFiles, 'august29_1957.csv', sep =''))
feb8_1999 <- read.csv(paste(dataFiles, 'feb8_1999.csv', sep =''))
feb19_2001 <- read.csv(paste(dataFiles, 'feb19_2001.csv', sep =''))
feb14_2000 <- read.csv(paste(dataFiles, 'feb14_2000.csv', sep =''))
jan7_1965 <- read.csv(paste(dataFiles, 'jan7_1965.csv', sep =''))
jan10_1986 <- read.csv(paste(dataFiles, 'jan10_1986.csv', sep =''))
jan11_1985 <- read.csv(paste(dataFiles, 'jan11_1985.csv', sep =''))
jan23_1969 <- read.csv(paste(dataFiles, 'jan23_1969.csv', sep =''))
jan30_1981 <- read.csv(paste(dataFiles, 'jan30_1981.csv', sep =''))
june2_1967 <-  read.csv(paste(dataFiles, 'june2_1967.csv', sep =''))
june13_1991 <-  read.csv(paste(dataFiles, 'june13_1991.csv', sep =''))
march2_1960 <-  read.csv(paste(dataFiles, 'march2_1960.csv', sep =''))
march3_1972 <-  read.csv(paste(dataFiles, 'march3_1972.csv', sep =''))
march3_1978 <-  read.csv(paste(dataFiles, 'march3_1978.csv', sep =''))
march29_1956 <-  read.csv(paste(dataFiles, 'march29_1956.csv', sep =''))
may11_1995 <-  read.csv(paste(dataFiles, 'may11_1995.csv', sep =''))
may19_1966 <-  read.csv(paste(dataFiles, 'may19_1966.csv', sep =''))
nov1_1953 <-  read.csv(paste(dataFiles, 'nov1_1953.csv', sep =''))
nov10_1972  <-  read.csv(paste(dataFiles, 'nov10_1972.csv', sep =''))
oct29_1971  <-  read.csv(paste(dataFiles, 'oct29_1971.csv', sep =''))
sept6_1994 <- read.csv(paste(dataFiles, 'sept6_1994.csv', sep=''))
may19_2003$question <- mapvalues(may19_2003$question, 
                                 from= c("Yes, in favor", "No, not", "DK","REF"), 
                                 to= c(1, 2 ,3, 4))


# april19_1976 1 white man 2 white woman 3 black man 4 black woman 
# 5 other man 6 other woman
april19_1976 <- april19_1976[april19_1976$age >= 18, ]
april19_1976$age <- cut(april19_1976$age, c(18,29, 44, 64, 150), labels= c(0,1,2,3))
april19_1976$genderrace <- factor(april19_1976$genderrace)
levels(april19_1976$genderrace)
x <- combineLevels(april19_1976$genderrace, levs = c("2", "4", "6"), newLabel = "F")
april19_1976 <- cbind(april19_1976, 1*(x == "F"))
y <- combineLevels(april19_1976$genderrace, levs = c("3", "4"), newLabel = "Black")
april19_1976 <- cbind(april19_1976, 1*(y=="Black"))
colnames(april19_1976)[7:8] <- c("gender", "race")
april19_1976 <- april19_1976[,-6]

april19_1976$educ <- factor(april19_1976$educ)

april19_1976$educ <- combineLevels(april19_1976$educ, levs='0', newLabel = 'four')
april19_1976$educ <-  combineLevels(april19_1976$educ, levs=c('1','2','3'), newLabel = '0')
april19_1976$educ <- combineLevels(april19_1976$educ, levs=c('4', '5'), newLabel = '1')
april19_1976$educ <- combineLevels(april19_1976$educ, levs = c('6', '7'), newLabel = '2')
april19_1976$educ <-combineLevels(april19_1976$educ, levs = '8', newLabel = '3')
table(april19_1976$educ)
april19_1976 <-  april19_1976[april19_1976$educ !='four',]
levels(april19_1976$educ)[1] <- '4'
table(april19_1976$educ)

# august 29 1957 
august29_1957$genderrace <-factor(august29_1957$genderrace)
levels(august29_1957$genderrace)
august29_1957 <- august29_1957[august29_1957$genderrace != "0", ]
august29_1957 <- fixData(august29_1957, 4, 5, c("2", "4"), c("3","4"))

august29_1957$educ <- factor(august29_1957$educ)
august29_1957 <- august29_1957[august29_1957$educ != '0', ]
august29_1957$educ <- combineLevels(august29_1957$educ, c('1', '2', '3'), newLabel = '0')
august29_1957$educ <- combineLevels(august29_1957$educ, c('4', '5'), newLabel = '1')
august29_1957$educ <- combineLevels(august29_1957$educ, c('6'), newLabel = '2')
august29_1957$educ <- combineLevels(august29_1957$educ, c('7', '8', '9'), newLabel = '3')
august29_1957$educ <- combineLevels(august29_1957$educ, c('10'), newLabel = '4')

# # feb 14 2000
feb14_2000$gender <-factor(feb14_2000$gender)
levels(feb14_2000$gender)
levels(feb14_2000$gender) <- c('0', '1')
feb14_2000$race <- factor(feb14_2000$race)
feb14_2000 <- feb14_2000[feb14_2000$race != 4, ]
feb14_2000$race <- factor(feb14_2000$race)
feb14_2000$race <-  combineLevels(feb14_2000$race, levs = c('1', '3'), newLabel = 'nonblack')
levels(feb14_2000$race) <- c('1', '0')

feb14_2000 <- cutAges(feb14_2000, 2)
feb14_2000$educ <- factor(feb14_2000$educ)
feb14_2000 <- feb14_2000[feb14_2000$educ != '9', ]
feb14_2000$educ <- factor(feb14_2000$educ)
feb14_2000$educ <- combineLevels(feb14_2000$educ, levs=c('1', '2', '3'), newLabel = '0')
feb14_2000$educ <- combineLevels(feb14_2000$educ, levs=c('4', '5'), newLabel = '1')
feb14_2000$educ <- combineLevels(feb14_2000$educ, levs=c('6', '7'), newLabel = '2')
feb14_2000$educ <- combineLevels(feb14_2000$educ, levs=c('8'), newLabel = '3')


# # feb 19 2001
feb19_2001 <- feb19_2001[-which(is.na(feb19_2001$question)), ]
feb19_2001 <- cutAges(feb19_2001, 2)
feb19_2001$gender <- factor(feb19_2001$gender)
levels(feb19_2001$gender) <- c("0", "1")
feb19_2001$race <- factor(feb19_2001$race)
levels(feb19_2001$race)
feb19_2001 <- feb19_2001[feb19_2001$race != 4, ]
feb19_2001$race <- factor(feb19_2001$race)
feb19_2001$race <- combineLevels(feb19_2001$race, c('1', '3'), 'nonblack')
levels(feb19_2001$race) <- c('1', '0')

feb19_2001$educ <- factor(feb19_2001$educ)
levels(feb19_2001$educ)
feb19_2001 <- feb19_2001[feb19_2001$educ != '9',]
feb19_2001$educ <- combineLevels(feb19_2001$educ, levs=c('1', '2', '3'), newLabel = '0')
feb19_2001$educ <- combineLevels(feb19_2001$educ, levs=c('4', '5'), newLabel = '1')
feb19_2001$educ <- combineLevels(feb19_2001$educ, levs=c('6', '7'), newLabel = '2')
feb19_2001$educ <- combineLevels(feb19_2001$educ, levs=c('8'), newLabel = '3')

# feb19_2001$educ <- factor(feb19_2001$educ)
# table(feb19_2001$educ)

# feb 8 1999
feb8_1999 <- cutAges(feb8_1999, 2)
feb8_1999$educ <- factor(feb8_1999$educ)
levels(feb8_1999$educ)
feb8_1999$educ <- combineLevels(feb8_1999$educ, levs=c('2', '3'), newLabel= '0')
feb8_1999$educ <- combineLevels(feb8_1999$educ, levs= c('4', '5'), newLabel = '1')
feb8_1999$educ <- combineLevels(feb8_1999$educ, levs = c('6', '7'), newLabel = '2')
feb8_1999$educ <- combineLevels(feb8_1999$educ, levs ='8', newLabel = '3')

feb8_1999$gender <- factor(feb8_1999$gender)
levels(feb8_1999$gender) <- c('0', '1')
feb8_1999$race <- factor(feb8_1999$race) 
table(feb8_1999$race)
feb8_1999 <- feb8_1999[feb8_1999$race != 3,]
feb8_1999$race <- factor(feb8_1999$race)
levels(feb8_1999$race)
feb8_1999$race <- combineLevels(feb8_1999$race, levs = c("1", "6", "8"), newLabel = "nonblack")
levels(feb8_1999$race)
levels(feb8_1999$race) <- c('1', '0')


# jan 10 1986

jan10_1986$gender <- factor(jan10_1986$gender)
levels(jan10_1986$gender) <- c("0", "1")
jan10_1986 <- cutAges(jan10_1986, 2)
jan10_1986$race <- factor(jan10_1986$race)
levels(jan10_1986$race)
jan10_1986 <- jan10_1986[jan10_1986$race != 3, ]
jan10_1986$race <- factor(jan10_1986$race)
levels(jan10_1986$race) <- c('0', '1')

jan10_1986$educ <- factor(jan10_1986$educ)
table(jan10_1986$educ)
jan10_1986 <- jan10_1986[jan10_1986$educ != 0, ]
jan10_1986$educ <- factor(jan10_1986$educ)
jan10_1986$educ <- combineLevels(jan10_1986$educ, levs=c('1', '2', '3'), newLabel = '0')
jan10_1986$educ <- combineLevels(jan10_1986$educ, levs=c('4', '5'), newLabel = '1')
jan10_1986$educ <- combineLevels(jan10_1986$educ, levs=c('6', '7'), newLabel = '2')
jan10_1986$educ <- combineLevels(jan10_1986$educ, levs=c('8'), newLabel = '3')

# jan 11 1985
jan11_1985 <- cutAges(jan11_1985, 2)
jan11_1985$gender <-factor(jan11_1985$gender)
levels(jan11_1985$gender) <- c("0", "1")
jan11_1985$race <-  factor(jan11_1985$race)
table(jan11_1985$race)
jan11_1985 <- jan11_1985[jan11_1985$race != '3', ]
jan11_1985$race <- factor(jan11_1985$race)
levels(jan11_1985$race) <- c('0', '1')

# jan 23 1969
jan23_1969$genderrace <- factor(jan23_1969$genderrace)
levels(jan23_1969$genderrace)
jan23_1969 <- fixData(jan23_1969, 1, 6, c("2", "4", "6"), c("3","4"))

jan23_1969$educ <- factor(jan23_1969$educ)
table(jan23_1969$educ)
jan23_1969$educ <- combineLevels(jan23_1969$educ, levs=c('1', '2', '3'), newLabel='0')
jan23_1969$educ <- combineLevels(jan23_1969$educ, levs=c('4','5'), newLabel='1')
jan23_1969$educ <- combineLevels(jan23_1969$educ, levs=c('6', '7'), newLabel='2')
jan23_1969$educ <- combineLevels(jan23_1969$educ, levs=c('8'), newLabel='3')

# jan 7 1965
jan7_1965$genderrace <- factor(jan7_1965$genderrace)
levels(jan7_1965$genderrace)
jan7_1965 <- fixData(jan7_1965, 4,5, c("2", "4", "6"), c("3","4"))
jan7_1965$educ <- factor(jan7_1965$educ)
table(jan7_1965$educ)
jan7_1965$educ <- combineLevels(jan7_1965$educ, levs=c('1', '2', '3'), newLabel='0')
jan7_1965$educ <- combineLevels(jan7_1965$educ, levs=c('4','5'), newLabel='1')
jan7_1965$educ <- combineLevels(jan7_1965$educ, levs=c('6', '7'), newLabel='2')
jan7_1965$educ <- combineLevels(jan7_1965$educ, levs=c('8'), newLabel='3')


# jan 30 1981
jan30_1981$genderrace <- factor(jan30_1981$genderrace)
levels(jan30_1981$genderrace)
jan30_1981 <- fixData(jan30_1981, 1, 6 , c("2", "4", "6"), c("3","4"))

jan30_1981$educ <- factor(jan30_1981$educ)
table(jan30_1981$educ)
jan30_1981 <- jan30_1981[jan30_1981$educ != 0, ]
jan30_1981$educ <- combineLevels(jan30_1981$educ, levs=c('1', '2', '3'), newLabel='0')
jan30_1981$educ <- combineLevels(jan30_1981$educ, levs=c('4','5'), newLabel='1')
jan30_1981$educ <- combineLevels(jan30_1981$educ, levs=c('6', '7'), newLabel='2')
jan30_1981$educ <- combineLevels(jan30_1981$educ, levs=c('8'), newLabel='3')

# june 13 1991
june13_1991 <- cutAges(june13_1991, 2)
june13_1991$gender <- factor(june13_1991$gender)
levels(june13_1991$gender) <- c("0", "1")
june13_1991 <- june13_1991[june13_1991$race != 4, ]
june13_1991$race <- factor(june13_1991$race)
levels(june13_1991$race)
june13_1991$race <- combineLevels(june13_1991$race, levs= c('1', '3'), newLabel = 'nonblack')
levels(june13_1991$race) <-c('1', '0')

june13_1991$educ <- factor(june13_1991$educ)
table(june13_1991$educ)
june13_1991 <- june13_1991[june13_1991$educ != 9, ]
june13_1991$educ <- combineLevels(june13_1991$educ, levs=c('1', '2', '3'), newLabel='0')
june13_1991$educ <- combineLevels(june13_1991$educ, levs=c('4','5'), newLabel='1')
june13_1991$educ <- combineLevels(june13_1991$educ, levs=c('6', '7'), newLabel='2')
june13_1991$educ <- combineLevels(june13_1991$educ, levs=c('8'), newLabel='3')

# june 2 1967
june2_1967$genderrace <- factor(june2_1967$genderrace)
levels(june2_1967$genderrace)
june2_1967 <- fixData(june2_1967, 1, 4, c("2", "4", "6"), c("3","4"))

june2_1967$educ <- factor(june2_1967$educ)
table(june2_1967$educ)
june2_1967 <- june2_1967[june2_1967$educ != 0, ]
june2_1967$educ <- combineLevels(june2_1967$educ, levs=c('1', '2', '3'), newLabel='0')
june2_1967$educ <- combineLevels(june2_1967$educ, levs=c('4','5'), newLabel='1')
june2_1967$educ <- combineLevels(june2_1967$educ, levs=c('6', '7'), newLabel='2')
june2_1967$educ <- combineLevels(june2_1967$educ, levs=c('8'), newLabel='3')

# march 2 1960
march2_1960$genderrace <- factor(march2_1960$genderrace)
levels(march2_1960$genderrace)
march2_1960 <- march2_1960[march2_1960$genderrace != "0", ]
march2_1960 <- fixData(march2_1960, 5, 4, c("2", "4", "6"), c("3","4"))

march2_1960$educ <- factor(march2_1960$educ)
table(march2_1960$educ)
march2_1960 <- march2_1960[march2_1960$educ != 0, ]
march2_1960$educ <- combineLevels(march2_1960$educ, levs=c('1', '2', '3'), newLabel='0')
march2_1960$educ <- combineLevels(march2_1960$educ, levs=c('4','5'), newLabel='1')
march2_1960$educ <- combineLevels(march2_1960$educ, levs=c('6', '7'), newLabel='2')
march2_1960$educ <- combineLevels(march2_1960$educ, levs=c('8'), newLabel='3')

# march 29 1956
march29_1956 <- cutAges(march29_1956, 2)
march29_1956$gender <- factor(march29_1956$gender)
levels(march29_1956$gender) <- c('0', '1')
march29_1956$race <- factor(march29_1956$race) 
march29_1956 <-  march29_1956[march29_1956$race !='0', ]
march29_1956$race <- factor(march29_1956$race)
levels(march29_1956$race) <- c('0', '1')

march29_1956$educ <- factor(march29_1956$educ)
table(march29_1956$educ)
march29_1956$educ <- combineLevels(march29_1956$educ, levs=c('1', '2', '3'), newLabel='0')
march29_1956$educ <- combineLevels(march29_1956$educ, levs=c('4','5'), newLabel='1')
march29_1956$educ <- combineLevels(march29_1956$educ, levs=c('6', '7'), newLabel='2')
march29_1956$educ <- combineLevels(march29_1956$educ, levs=c('8', '9', '10'), newLabel='3')

# march 3 1972
march3_1972$genderrace <- factor(march3_1972$genderrace)
march3_1972 <- march3_1972[march3_1972$genderrace != "0", ]
levels(march3_1972$genderrace)
march3_1972 <- fixData(march3_1972, 2, 6, c('2', '4', '6'), c('3', '4'))

march3_1972$educ <- factor(march3_1972$educ)
table(march3_1972$educ)
march3_1972 <-march3_1972[march3_1972$educ != 0, ]
march3_1972$educ <- combineLevels(march3_1972$educ, levs=c('1', '2', '3'), newLabel='0')
march3_1972$educ <- combineLevels(march3_1972$educ, levs=c('4','5'), newLabel='1')
march3_1972$educ <- combineLevels(march3_1972$educ, levs=c('6', '7'), newLabel='2')
march3_1972$educ <- combineLevels(march3_1972$educ, levs=c('8'), newLabel='3')

# march 3 1978
march3_1978$genderrace <- factor(march3_1978$genderrace)
march3_1978 <- march3_1978[march3_1978$genderrace != "0", ]
levels(march3_1978$genderrace)
march3_1978 <- fixData(march3_1978, 1, 6, c('2', '4', '6'), c('3', '4'))

march3_1978$educ <- factor(march3_1978$educ)
table(march3_1978$educ)
march3_1978 <-march3_1978[march3_1978$educ != 0, ]
march3_1978$educ <- combineLevels(march3_1978$educ, levs=c('1', '2', '3'), newLabel='0')
march3_1978$educ <- combineLevels(march3_1978$educ, levs=c('4','5'), newLabel='1')
march3_1978$educ <- combineLevels(march3_1978$educ, levs=c('6', '7'), newLabel='2')
march3_1978$educ <- combineLevels(march3_1978$educ, levs=c('8'), newLabel='3')

# may 11 1995
may11_1995 <- cutAges(may11_1995, 2)
may11_1995$race <- factor(may11_1995$race)
table(may11_1995$race)
may11_1995 <- may11_1995[may11_1995$race != 2 & may11_1995$race != 3, ] 
may11_1995$race <- factor(may11_1995$race)
levels(may11_1995$race)
may11_1995$race <- combineLevels(may11_1995$race, levs = c('1', '6', '8'), newLabel = 'nonblack')
levels(may11_1995$race ) <- c('1', '0')

may11_1995$gender <- factor(may11_1995$gender)
levels(may11_1995$gender) <- c('0', '1')

may11_1995$educ <- factor(may11_1995$educ)
table(may11_1995$educ)
may11_1995 <-may11_1995[may11_1995$educ != 9, ]
may11_1995$educ <- combineLevels(may11_1995$educ, levs=c('1', '2', '3'), newLabel='0')
may11_1995$educ <- combineLevels(may11_1995$educ, levs=c('4','5'), newLabel='1')
may11_1995$educ <- combineLevels(may11_1995$educ, levs=c('6', '7'), newLabel='2')
may11_1995$educ <- combineLevels(may11_1995$educ, levs=c('8'), newLabel='3')

# may 19 1966
may19_1966$genderrace <- factor(may19_1966$genderrace)
may19_1966 <- may19_1966[may19_1966$genderrace != "0", ]
levels(may19_1966$genderrace)
may19_1966 <- fixData(may19_1966, 5, 4, c('1', '2', '3'), c('3', '4'))

may19_1966$educ <- factor(may19_1966$educ)
table(may19_1966$educ)
may19_1966 <-may19_1966[may19_1966$educ != 0, ]
may19_1966$educ <- combineLevels(may19_1966$educ, levs=c('1', '2', '3'), newLabel='0')
may19_1966$educ <- combineLevels(may19_1966$educ, levs=c('4','5'), newLabel='1')
may19_1966$educ <- combineLevels(may19_1966$educ, levs=c('6', '7'), newLabel='2')
may19_1966$educ <- combineLevels(may19_1966$educ, levs=c('8'), newLabel='3')

# may 19 2003
may19_2003 <- cutAges(may19_2003, 5)
may19_2003$gender <- factor(may19_2003$gender)
levels(may19_2003$gender) <- c("0", "1")
levels(may19_2003$race)
may19_2003$race <- combineLevels(may19_2003$race, levs = c("white", "other"), newLabel = "nonblack")
may19_2003 <- may19_2003[may19_2003$race != 'ref',]
may19_2003$race <- factor(may19_2003$race)
levels(may19_2003$race) <- c("1", "0")

may19_2003$educ <- factor(may19_2003$educ)
levels(may19_2003$educ)
may19_2003 <- may19_2003[may19_2003$educ != 'DK/REF', ]
may19_2003$educ <- combineLevels(may19_2003$educ, 
                                 levs=c('None up to Grade 4', 'Grades 5-7', 'Grade 8'), 
                                 newLabel = '0')
may19_2003$educ <- combineLevels(may19_2003$educ, levs=c('High school incomplete (Grade 9-11)',
                                                         'High School Graduate (Grade 12)'),
                                 newLabel = '1')
may19_2003$educ <- combineLevels(may19_2003$educ, levs=c('Technical/Trade/Business after high school',
                                                         'College/university incomplete'),
                                 newLabel = '2')
may19_2003$educ <-combineLevels(may19_2003$educ, levs='College/university graduate', '3')

# may 5 2006 1 white 2 black 3 other 4 na
may5_2006 <- may5_2006[- which(is.na(may5_2006$question)), ]
may5_2006 <- cutAges(may5_2006, 2)
may5_2006$race <- factor(may5_2006$race)
table(may5_2006$race)
may5_2006 <- may5_2006[-which(may5_2006$race == 4), ]
may5_2006$race <- factor(may5_2006$race)
may5_2006$race <- combineLevels(may5_2006$race, c('1', '3'), 'nonblack')
levels(may5_2006$race) <- c(1, 0)

may5_2006$gender <- factor(may5_2006$gender)
levels(may5_2006$gender) <- c(0, 1)
levels(may5_2006$gender)

may5_2006$educ <- factor(may5_2006$educ)
table(may5_2006$educ)
may5_2006$educ <- combineLevels(may5_2006$educ, c('1', '3', '4'), newLabel = '0')
may5_2006$educ <- combineLevels(may5_2006$educ, c('5'), '1')
may5_2006$educ <- combineLevels(may5_2006$educ, c('6', '7'), '2')
may5_2006$educ <- combineLevels(may5_2006$educ, c('8'), '3')
may5_2006 <- may5_2006[-which(may5_2006$educ == '9'), ]
may5_2006$educ <-  factor(may5_2006$educ)
levels(may5_2006$educ)

# nov 1 1953
nov1_1953 <- cutAges(nov1_1953, 2)
nov1_1953$gender <- factor(nov1_1953$gender)
nov1_1953 <- nov1_1953[ -which(nov1_1953$gender == 0), ]
nov1_1953$gender <- factor(nov1_1953$gender)
levels(nov1_1953$gender) <- c('0', '1')
nov1_1953$race <- factor(nov1_1953$race)
nov1_1953 <- nov1_1953[nov1_1953$race != '0', ]
nov1_1953$race <-  factor(nov1_1953$race)
levels(nov1_1953$race) <- c('0', '1')

nov1_1953$educ <- factor(nov1_1953$educ)
table(nov1_1953$educ)
nov1_1953 <-nov1_1953[nov1_1953$educ != 0, ]
nov1_1953$educ <- combineLevels(nov1_1953$educ, levs=c('1', '2', '3'), newLabel='0')
nov1_1953$educ <- combineLevels(nov1_1953$educ, levs=c('4','5'), newLabel='1')
nov1_1953$educ <- combineLevels(nov1_1953$educ, levs=c('6', '7'), newLabel='2')
nov1_1953$educ <- combineLevels(nov1_1953$educ, levs=c('8', '9', '10'), newLabel='3')

# nov 10 1972
nov10_1972$genderrace <- factor(nov10_1972$genderrace)
nov10_1972 <- nov10_1972[nov10_1972$genderrace != '0', ]
levels(nov10_1972$genderrace)
str(nov10_1972)
nov10_1972 <- fixData(nov10_1972, 6, 1, c('1', '2', '3'), c('3', '4'))

nov10_1972$educ <- factor(nov10_1972$educ)
table(nov10_1972$educ)
nov10_1972 <-nov10_1972[nov10_1972$educ != 0, ]
nov10_1972$educ <- combineLevels(nov10_1972$educ, levs=c('1', '2', '3'), newLabel='0')
nov10_1972$educ <- combineLevels(nov10_1972$educ, levs=c('4','5'), newLabel='1')
nov10_1972$educ <- combineLevels(nov10_1972$educ, levs=c('6', '7'), newLabel='2')
nov10_1972$educ <- combineLevels(nov10_1972$educ, levs=c('8'), newLabel='3')

# oct 29 1971
oct29_1971$genderrace <- factor(oct29_1971$genderrace)
oct29_1971 <- oct29_1971[oct29_1971$genderrace != '0', ]
levels(oct29_1971$genderrace)
oct29_1971 <- fixData(oct29_1971, 1, 6, c('1', '2', '3'), c('3', '4'))

oct29_1971$educ <- factor(oct29_1971$educ)
table(oct29_1971$educ)
oct29_1971 <-oct29_1971[oct29_1971$educ != 0, ]
oct29_1971$educ <- combineLevels(oct29_1971$educ, levs=c('1', '2', '3'), newLabel='0')
oct29_1971$educ <- combineLevels(oct29_1971$educ, levs=c('4','5'), newLabel='1')
oct29_1971$educ <- combineLevels(oct29_1971$educ, levs=c('6', '7'), newLabel='2')
oct29_1971$educ <- combineLevels(oct29_1971$educ, levs=c('8'), newLabel='3')

# sept 6 1994
sept6_1994$gender <- factor(sept6_1994$gender)
levels(sept6_1994$gender) <- c("0", "1")
sept6_1994 <- cutAges(sept6_1994, 2)
sept6_1994$race <- factor(sept6_1994$race)
sept6_1994 <- sept6_1994[sept6_1994$race != 2, ]
sept6_1994 <- sept6_1994[sept6_1994$race != 3, ]
sept6_1994 <- sept6_1994[sept6_1994$race != 4, ]
sept6_1994 <- sept6_1994[sept6_1994$race != 5, ]
sept6_1994$race <- factor(sept6_1994$race)
sept6_1994$race <- combineLevels(sept6_1994$race, levs = c('1', '6', '8'), newLabel = 'nonblack')
levels(sept6_1994$race) <- c('1', '0')

sept6_1994$educ <- factor(sept6_1994$educ)
table(sept6_1994$educ)
sept6_1994 <-sept6_1994[sept6_1994$educ != 9, ]
sept6_1994$educ <- combineLevels(sept6_1994$educ, levs=c('1', '2', '3'), newLabel='0')
sept6_1994$educ <- combineLevels(sept6_1994$educ, levs=c('4','5'), newLabel='1')
sept6_1994$educ <- combineLevels(sept6_1994$educ, levs=c('6', '7'), newLabel='2')
sept6_1994$educ <- combineLevels(sept6_1994$educ, levs=c('8'), newLabel='3')

# Standarizing date
april19_1976 <- bindDate(april19_1976,  1976)
august29_1957 <- bindDate(august29_1957, 1957)
feb14_2000 <- bindDate(feb14_2000,  2000)
feb19_2001 <- bindDate(feb19_2001,  2001)
feb8_1999 <- bindDate(feb8_1999, 1999)
jan10_1986 <- bindDate(jan10_1986, 1986)
jan11_1985 <- bindDate(jan11_1985, 1985)
jan23_1969 <- bindDate(jan23_1969, 1969)
jan30_1981 <- bindDate(jan30_1981, 1981)
jan7_1965 <- bindDate(jan7_1965, 1965)
june13_1991 <- bindDate(june13_1991, 1991)
june2_1967 <- bindDate(june2_1967, 1967)
march2_1960 <- bindDate(march2_1960, 1960)
march29_1956 <- bindDate(march29_1956, 1956)
march3_1972 <- bindDate(march3_1972, 1972)
march3_1978 <- bindDate(march3_1978, 1978)
may11_1995 <- bindDate(may11_1995, 1995)
may19_1966 <- bindDate(may19_1966, 1966)
may19_2003 <- bindDate(may19_2003, 2003)
may5_2006 <- bindDate(may5_2006, 2006)
nov1_1953 <-bindDate(nov1_1953, 1953)
nov10_1972 <- bindDate(nov10_1972, 1972)
oct29_1971 <- bindDate( oct29_1971, 1971)
sept6_1994 <- bindDate(sept6_1994, 1994)

# Remove unsures in question

april19_1976$question <-factor(april19_1976$question)
april19_1976$race <- factor(april19_1976$race)
april19_1976$gender <- factor(april19_1976$gender)


table(april19_1976$question == 4)
april1976 <- orderAndCleanData(april19_1976, 2)
august1957 <- orderAndCleanData(august29_1957, 3)
feb2000 <- orderAndCleanData(feb14_2000, 3)
feb2001 <- orderAndCleanData(feb19_2001, 3)
feb1999 <- orderAndCleanData(feb8_1999, 3)
jan1986 <- orderAndCleanData(jan10_1986, 3)
jan1985 <- orderAndCleanData(jan11_1985, 3)
jan1969 <- orderAndCleanData(jan23_1969, 2)
jan1981 <- orderAndCleanData(jan30_1981, 2)
jan1965 <- orderAndCleanData(jan7_1965, 3)
june1991 <- orderAndCleanData(june13_1991, 3)
june1967 <- orderAndCleanData(june2_1967, 3)
march1960 <- orderAndCleanData(march2_1960, 1)
march1956 <- orderAndCleanData(march29_1956, 3)
march1972 <- orderAndCleanData(march3_1972, 3)
march1978 <- orderAndCleanData(march3_1978, 2)
may1995 <- orderAndCleanData(may11_1995, 3)
may1966 <- orderAndCleanData(may19_1966, 1)
may2003 <- orderAndCleanData(may19_2003, 7)
may2006 <- orderAndCleanData(may5_2006, 3)
nov1953 <- orderAndCleanData(nov1_1953, 3)
nov1972 <- orderAndCleanData(nov10_1972, 1)
oct1971 <- orderAndCleanData(oct29_1971, 2)
sept1994 <- orderAndCleanData(sept6_1994, 3)

rm(april19_1976, august29_1957, feb14_2000, feb19_2001, feb8_1999, jan10_1986, jan11_1985, jan23_1969,
   jan30_1981, jan7_1965, june13_1991, june2_1967, march2_1960, march29_1956, march3_1972, march3_1978,
   may11_1995, may19_1966, may19_2003, may5_2006, nov1_1953, nov10_1972, oct29_1971, sept6_1994)

august1957$question <- factor(august1957$question)
august1957$race <- factor(august1957$race)
august1957$gender <-  factor(august1957$gender)

feb1999$question <- factor(feb1999$question)

feb2001$question <- factor(feb2001$question)

jan1965$question <- factor(jan1965$question)
jan1965$race <- factor(jan1965$race)
jan1965$gender <- factor(jan1965$gender)

jan1969$question <- factor(jan1969$question)
jan1969$race <- factor(jan1969$race)
jan1969$gender <- factor(jan1969$gender)

jan1981$question <- factor(jan1981$question)
jan1981$race <- factor(jan1981$race)
jan1981$gender <- factor(jan1981$gender)

jan1985$question <- factor(jan1985$question)
jan1985$educ <- factor(jan1985$educ)

jan1986$question <- factor(jan1986$question)

june1967$question <- factor(june1967$question)
june1967$race <- factor(june1967$race)
june1967$gender <- factor(june1967$gender)

june1991$question <- factor(june1991$question)

march1956$question <- factor(march1956$question)

march1960$question <- factor(march1960$question)
march1960$race <- factor(march1960$race)
march1960$gender <- factor(march1960$gender)

march1972$question <- factor(march1972$question)
march1972$race <- factor(march1972$race)
march1972$gender <- factor(march1972$gender)

march1978$question <- factor(march1978$question)
march1978$race <- factor(march1978$race)
march1978$gender <- factor(march1978$gender)

may1966$question <- factor(may1966$question)
may1966$race <- factor(may1966$race)
may1966$gender <- factor(may1966$gender)

may1995$question <- factor(may1995$question)
levels(may2003$state)
levels(may2003$state) <- c("11", "12", "13", "14", "15", "16", "21", "22", "23", "24", "25",
                           "26", "27", "31", "32", "33", "34", "41", "42", "43", "44", "45",
                           "46", "47", "48", "51", "52", "53", "54", "55", "56", "57", "58",
                           "59", "61", "62", "63", "64", "71", "72", "73", "74", "75", "76",
                           "77", "78", "81", "82", "83", "84", "85")

may2003$state <- as.integer(as.character(may2003$state))

may2006$question <- factor(may2006$question)

table(nov1953$question == 1)["TRUE"] /( table(nov1953$question == 1)["TRUE"] + table(nov1953$question ==2)["TRUE"])
test <- nov1953$question - 1
table(nov1953$question == 1)["TRUE"]
length(which(test == 1))
test
nov1953$question == 1
length(which(test == 0)) / (length(which(test == 0))  + length(which(test == 1)))
nov1953$question <- factor(nov1953$question)



nov1972$question <- factor(nov1972$question)
nov1972$race <- factor(nov1972$race)
nov1972$gender <- factor(nov1972$gender)

oct1971$question <- factor(oct1971$question)
oct1971$race <- factor(oct1971$race)
oct1971$gender <- factor(oct1971$gender)

sept1994$question <- factor(sept1994$question)

allData <- as.data.frame(rbind(april1976, august1957, feb1999, feb2000, feb2001, jan1965, jan1969, jan1986, jan1981, 
                 jan1985, jan1986, june1967, june1991, march1956, march1960, march1972, march1978,
                 may1966, may1995, may2003, may2006, nov1953, nov1972, oct1971, sept1994))

allData <- allData[complete.cases(allData), ]

test <- allData[allData$time== -27, ]
mean(as.numeric(as.character(test$question)) - 1)
# standarize variables
mRace <- mean(as.numeric(as.character(allData$race)))
sdRace <- sd(as.numeric(as.character(allData$race)))
allData$race <-  (as.numeric(as.character(allData$race)) - mRace) / sdRace

mGender <- mean(as.numeric(as.character(allData$gender)))
sdGender <- sd(as.numeric(as.character(allData$gender)))
allData$gender <- (as.numeric(as.character(allData$gender)) - mGender) /sdGender

# paste in legality
allData <- merge(allData, usStates, by='state')

# Get states by region
south <- c(58, 61, 25,27, 55,54,58,56, 62, 24, 59, 63, 53, 57, 64, 26, 52)
west <- c(72, 73, 74, 71, 77, 82, 83, 75, 76, 85, 84, 78, 81)
midwest <- c(48, 44, 34, 33, 43, 32, 42, 47, 45, 31, 46, 41)
north <- c(11, 13, 12, 23, 22, 14, 16, 15, 21)
length(north)
length(south)
length(north) + length(south)
length(midwest)
length(north) + length(south) + length(midwest)
length(west)
length(north) + length(south) + length(midwest) +length(west)
region <- 0
regionKeys <- as.data.frame(matrix(0, nrow=51, ncol=2))
k <- 0
u <- 0
m <- 0
for(i in 1:51){
  if( i <= 17){
    regionKeys[i,1] <- 1
    regionKeys[i, 2] <- south[i]
  }
  else if((i > 17) & (i <= 30)){
    k <- k + 1
    regionKeys[i, 1] <- 2
    regionKeys[i, 2] <- west[k]
  }
  else if((i > 31) & (i <= 43)){
    u <- u + 1
    regionKeys[i, 1] <- 3
    regionKeys[i, 2] <- midwest[u]
  }
  else{
    m <- m + 1
    regionKeys[i, 1] <- 4
    regionKeys[i, 2] <- north[m]
  }
}

regionKeys <- regionKeys[order(regionKeys$V2), ]
colnames(regionKeys) <- c('region', 'statecodes')
for(i in 1:nrow(allData)){
  if(is.element(allData[i, 1], north)){
    region[i] <- 1
  }
  else if(is.element(allData[i, 1], south)){
    region[i] <- 2
  }
  else if(is.element(allData[i, 1], midwest)){
    region[i] <- 3
  }
  else{
    region[i] <- 4
  }
}
allData <- cbind(allData, region)

# republican share
library(readxl)
election1952 <- read_excel("~/Google Drive/CodeProjects/R/election1952.xlsx")
election1952 <- election1952[-c(49:52), ]
election1956 <- read_excel("~/Google Drive/CodeProjects/R/election1956.xlsx")
election1956 <- election1956[-c(49:52), ]
election1956 <- election1956[, -c(7:8)]
election1960 <- read_excel("~/Google Drive/CodeProjects/R/election1960.xlsx")
election1960 <- election1960[-c(51:53), -c(7:8)]
election1964 <- read_excel("~/Google Drive/CodeProjects/R/election1964.xlsx")
election1964 <- election1964[-c(52:55), ]
election1964 <- election1964[,-c(7,8)]
election1968 <- read_excel("~/Google Drive/CodeProjects/R/election1968.xlsx")
election1968 <- election1968[-c(52:54), -c(7:11)]
election1972 <- read_excel("~/Google Drive/CodeProjects/R/election1972.xlsx")
election1972 <- election1972[-c(52:55), ]
election1976 <- read_excel("~/Google Drive/CodeProjects/R/election1976.xlsx")
election1976 <- election1976[-c(52:55), -c(7:8)]
election1980 <- read_excel("~/Google Drive/CodeProjects/R/election1980.xlsx")
election1980 <- election1980[-c(52:54), -c(7:11)]
election1984 <- read_excel("~/Google Drive/CodeProjects/R/election1984.xlsx")
election1984 <- election1984[-c(52:53), -c(7:8)]
election1988 <- read_excel("~/Google Drive/CodeProjects/R/election1988.xlsx")
election1988 <- election1988[-c(52:55), -c(7:8)]
election1992 <- read_excel("~/Google Drive/CodeProjects/R/election1992.xlsx")
election1992 <- election1992[-c(52:55), -c(7:11)]
election1996 <- read_excel("~/Google Drive/CodeProjects/R/election1996.xlsx")
election1996 <- election1996[-c(52:53), -c(7:11)]
election2000 <- read_excel("~/Google Drive/CodeProjects/R/election2000.xlsx")
election2000 <- election2000[-c(52:53), -c(7:11)]
election2004 <- read_excel("~/Google Drive/CodeProjects/R/election2004.xlsx")
election2004 <- election2004[-c(52:54), -c(7:8)]

election1952 <- subset(election1952, select = c('state', 'percentR'))
election1956 <- subset(election1956, select = c('state', 'percentR'))
election1960 <- subset(election1960, select = c('state', 'percentR'))
election1964 <- subset(election1964, select = c('state', 'percentR'))
election1968 <- subset(election1968, select = c('state', 'percentR'))
election1972 <- subset(election1972, select = c('state', 'percentR'))
election1976 <- subset(election1976, select = c('state', 'percentR'))
election1980 <- subset(election1980, select = c('state', 'percentR'))
election1984 <- subset(election1984, select = c('state', 'percentR'))
election1988 <- subset(election1988, select = c('state', 'percentR'))
election1992 <- subset(election1992, select = c('state', 'percentR'))
election1996 <- subset(election1996, select = c('state', 'percentR'))
election2000 <- subset(election2000, select = c('state', 'percentR'))
election2004 <- subset(election2004, select = c('state', 'percentR'))


allElections <- list(election1952, election1956, election1960, election1964, election1968,
                     election1972, election1976, election1980, election1984, election1988,
                     election1992, election1996, election2000, election2004)

al <- 0
alas <- 0
az <- 0
ar <- 0
ca <- 0
co <- 0
conn <- 0
del <- 0
flor <- 0
ge <- 0
ida <- 0
ill <- 0
ha <-0 
ind <- 0
iowa <- 0
kan <- 0
ken <- 0
lous <- 0
maine <- 0
mary <- 0
ma <- 0
mich <-0 
min <- 0
miss <-0
missouri <- 0
mon <- 0
neb <- 0
nev <- 0
nh <- 0
nj <- 0
nm <- 0
ny <- 0
nc <- 0
nd <- 0
ohio <- 0
ok <- 0
ore <- 0
penn <- 0
ri <- 0
sc <- 0
southd <- 0
tenn <- 0
tex <- 0
utah <- 0
ver <- 0
vir <- 0
wash <- 0
wv <- 0
wis <- 0
wy <- 0
dc <-0
for(i in 1:length(allElections)){
  frame <- allElections[[i]]
  al[i] <- unlist(frame[1,2])
  if(i < 3){
    az[i] <- unlist(frame[2,2])  
    ar[i] <- unlist(frame[3,2])
    ca[i] <- unlist(frame[4,2])
    co[i] <- unlist(frame[5,2])
    conn[i] <- unlist(frame[6,2])
    del[i] <- unlist(frame[7,2])
    flor[i] <- unlist(frame[8,2])
    ge[i] <- unlist(frame[9,2])
    ida[i] <- unlist(frame[10,2])
    ill[i] <- unlist(frame[11,2])
    ind[i] <- unlist(frame[12,2])
    iowa[i] <- unlist(frame[13,2])
    kan[i] <- unlist(frame[14,2])
    ken[i] <- unlist(frame[15,2])
    lous[i] <- unlist(frame[16,2])
    maine[i] <- unlist(frame[17,2])
    mary[i] <- unlist(frame[18,2]) 
    ma[i] <- unlist(frame[19,2]) 
    mich[i] <- unlist(frame[20,2])
    min[i] <- unlist(frame[21,2])
    miss[i] <- unlist(frame[22,2])
    missouri[i] <- unlist(frame[23, 2])
    mon[i] <- unlist(frame[24, 2])
    neb[i] <- unlist(frame[25, 2])
    nev[i] <- unlist(frame[26,2])
    nh[i] <- unlist(frame[27, 2])
    nj[i] <- unlist(frame[28 ,2])
    nm[i] <- unlist(frame[29, 2])
    ny[i] <- unlist(frame[30 ,2])
    nc[i] <- unlist(frame[31 ,2])
    nd[i] <- unlist(frame[32,2])
    ohio[i] <- unlist(frame[34, 2])
    ok[i] <- unlist(frame[34, 2])
    ore[i] <- unlist(frame[35, 2])
    penn[i] <- unlist(frame[36, 2])
    ri[i] <- unlist(frame[37, 2])
    sc[i] <- unlist(frame[38, 2])
    southd[i] <- unlist(frame[39, 2])
    tenn[i] <- unlist(frame[40, 2])
    tex[i] <- unlist(frame[41, 2])
    utah[i] <- unlist(frame[42, 2])
    ver[i] <- unlist(frame[43, 2])
    vir[i] <- unlist(frame[44, 2])
    wash[i] <- unlist(frame[45, 2])
    wv[i] <- unlist(frame[46, 2])
    wis[i] <- unlist(frame[47, 2])
    wy[i] <- unlist(frame[48 , 2])
  }
  else if(i == 2) {
    alas[i -2] <- unlist(frame[2,2]) 
    az[i] <- unlist(frame[3,2])
    ar[i] <- unlist(frame[4,2])
    ca[i] <- unlist(frame[5,2])
    co[i] <- unlist(frame[6,2])
    conn[i] <- unlist(frame[7,2])
    del[i] <- unlist(frame[7,2])
    flor[i] <- unlist(frame[9,2])
    ge[i] <- unlist(frame[10,2])
    ha[i-2] <- unlist(frame[11,2])
    ida[i] <- unlist(frame[12,2])
    ill[i] <- unlist(frame[13,2])
    ind[i] <- unlist(frame[14,2])
    iowa[i] <- unlist(frame[15,2])
    kan[i] <- unlist(frame[16,2])
    ken[i] <- unlist(frame[17,2])
    lous[i] <- unlist(frame[18,2])
    maine[i] <- unlist(frame[19,2])
    mary[i] <- unlist(frame[20,2]) 
    ma[i] <- unlist(frame[21,2]) 
    mich[i] <- unlist(frame[22,2]) 
    min[i] <- unlist(frame[23,2])
    miss[i] <- unlist(frame[24,2])
    missouri[i] <- unlist(frame[25, 2])
    mon[i] <- unlist(frame[26, 2])
    neb[i] <- unlist(frame[27, 2])
    nev[i] <- unlist(frame[28,2])
    nh[i] <- unlist(frame[29, 2])
    nj[i] <- unlist(frame[30 ,2])
    nm[i] <- unlist(frame[31, 2])
    ny[i] <- unlist(frame[32 ,2])
    nc[i] <- unlist(frame[33 ,2])
    nd[i] <- unlist(frame[34,2])
    ohio[i] <- unlist(frame[35, 2])
    ok[i] <- unlist(frame[36, 2])
    ore[i] <- unlist(frame[37, 2])
    penn[i] <- unlist(frame[38, 2])
    ri[i] <- unlist(frame[39, 2])
    sc[i] <- unlist(frame[40, 2])
    southd[i] <- unlist(frame[41, 2])
    tenn[i] <- unlist(frame[42, 2])
    tex[i] <- unlist(frame[43, 2])
    utah[i] <- unlist(frame[44, 2])
    ver[i] <- unlist(frame[45, 2])
    vir[i] <- unlist(frame[46, 2])
    wash[i] <- unlist(frame[47, 2])
    wv[i] <- unlist(frame[48, 2])
    wis[i] <- unlist(frame[49, 2])
    wy[i] <- unlist(frame[50, 2])
  }
  else{
    alas[i -2] <- unlist(frame[2,2]) 
    az[i] <- unlist(frame[3,2])
    ar[i] <- unlist(frame[4,2])
    ca[i] <- unlist(frame[5,2])
    co[i] <- unlist(frame[6,2])
    conn[i] <- unlist(frame[7,2])
    del[i] <- unlist(frame[7,2])
    
    dc[i] <- unlist(frame[9, 2])
    flor[i] <- unlist(frame[10,2])
    ge[i] <- unlist(frame[11,2])
    ha[i-2] <- unlist(frame[12,2])
    ida[i] <- unlist(frame[13,2])
    ill[i] <- unlist(frame[14,2])
    ind[i] <- unlist(frame[15,2])
    iowa[i] <- unlist(frame[16,2])
    kan[i] <- unlist(frame[17,2])
    ken[i] <- unlist(frame[18,2])
    lous[i] <- unlist(frame[19,2])
    maine[i] <- unlist(frame[20,2])
    mary[i] <- unlist(frame[21,2]) 
    ma[i] <- unlist(frame[22,2]) 
    mich[i] <- unlist(frame[23,2]) 
    min[i] <- unlist(frame[24,2])
    miss[i] <- unlist(frame[25,2])
    missouri[i] <- unlist(frame[26, 2])
    mon[i] <- unlist(frame[27, 2])
    neb[i] <- unlist(frame[28, 2])
    nev[i] <- unlist(frame[29,2])
    nh[i] <- unlist(frame[30, 2])
    nj[i] <- unlist(frame[31 ,2])
    nm[i] <- unlist(frame[32, 2])
    ny[i] <- unlist(frame[33 ,2])
    nc[i] <- unlist(frame[34 ,2])
    nd[i] <- unlist(frame[35,2])
    ohio[i] <- unlist(frame[36, 2])
    ok[i] <- unlist(frame[37, 2])
    ore[i] <- unlist(frame[38, 2])
    penn[i] <- unlist(frame[39, 2])
    ri[i] <- unlist(frame[40, 2])
    sc[i] <- unlist(frame[41, 2])
    southd[i] <- unlist(frame[42, 2])
    tenn[i] <- unlist(frame[43, 2])
    tex[i] <- unlist(frame[44, 2])
    utah[i] <- unlist(frame[45, 2])
    ver[i] <- unlist(frame[46, 2])
    vir[i] <- unlist(frame[47, 2])
    wash[i] <- unlist(frame[48, 2])
    wv[i] <- unlist(frame[49, 2])
    wis[i] <- unlist(frame[50, 2])
    wy[i] <- unlist(frame[51, 2])
  }
}
t0 = 1:14
t1 = 1:12
allm <- lm(al ~ t0)
alaslm <- lm(alas ~ t1)
azlm <- lm(az ~ t0)
arlm <- lm(ar ~ t0)
calm <- lm(ca ~ t0) 
colm <- lm(co~t0)
connlm <- lm(conn~t0)
dellm <- lm(del~t0)
florlm <- lm(flor~t0)
gelm <- lm(ge~t0)
ida <- lm(ida~t0)
illlm <- lm(ill~t0)
ha <- lm(ha~t1) 
indlm <- lm(ind~t0)
iowalm <- lm(iowa~t0)
kanlm <- lm(kan~t0)
kenlm <- lm(ken~t0)
louslm <- lm(lous~t0)
mainelm <- lm(maine~t0)
marylm <- lm(mary~t0)
malm <- lm(ma~t0)
michlm <- lm(mich~t0)
minlm <- lm(min~t0)
misslm <- lm(miss~t0)
missourilm <- lm(missouri~t0)
monlm <- lm(mon~t0)
neblm <- lm(neb~t0)
nevlm <- lm(nev~t0)
nhlm <-  lm(nh~t0)
njlm <- lm(nj~t0)
nmlm <- lm(nm~t0)
nylm <- lm(ny~t0)
nclm <- lm(nc~t0)
ndlm <- lm(nd~t0)
ohiolm <- lm(ohio~t0)
oklm <- lm(ok~t0)
orelm <- lm(ore~t0)
pennlm <- lm(penn~t0)
rilm <- lm(ri~t0)
sclm <- lm(sc~t0)
southdlm <- lm(southd~t0)
tennlm <- lm(tenn~t0)
texlm <- lm(tex~t0)
utahlm <- lm(utah~t0)
verlm <- lm(ver~t0)
virlm <- lm(vir~t0)
washlm <- lm(wash~t0)
wvlm <- lm(wv~t0)
wislm <- lm(wis~t0)
wylm <- lm(wy~t0)
dclm <-lm(dc~t0)

allregs <- list(allm, 
alaslm,
azlm,
arlm,
calm,
colm,
connlm,
dellm,dclm,
florlm,
gelm,
ida ,
illlm,
ha,
indlm, 
iowalm,
kanlm ,
kenlm ,
louslm ,
mainelm,
marylm,
malm ,
michlm, 
minlm ,
misslm ,
missourilm, 
monlm ,
neblm ,
nevlm ,
nhlm ,
njlm ,
nmlm ,
nylm ,
nclm ,
ndlm ,
ohiolm, 
oklm ,
orelm ,
pennlm ,
rilm,
sclm ,
southdlm,
tennlm,
texlm,
utahlm,
verlm ,
virlm,
washlm, 
wvlm ,
wislm ,
wylm)

repShare <- as.data.frame(matrix(0, nrow=51, ncol=2))

for(i in 1:length(allregs)){
  repShare[i, ] <- allregs[[i]][[1]]
}

repShare <- as.data.frame(cbind(election1964$state, repShare))
statecodes <- read_csv("~/Google Drive/CodeProjects/R/statecodes.csv", col_names = FALSE)
statecodes
repShare <- cbind(statecodes$X2, repShare)

allData <- allData[-which(allData$question == 5), ]
allData <- allData[-which(allData$question == 0), ]
zState <- repShare[,c(1,3)]
xState <- repShare[, c(1, 4)]
xState <- as.data.frame(cbind(zState, usStates$legality))
zState <- as.data.frame(cbind(xState, usStates$legality))

table(allData$educ)
allData$educ[allData$educ == 5] = 2
allData$educ[allData$educ == 6] = 3
allData$educ[allData$educ == 7] = 3
allData$educ[allData$educ == 8] = 3
allData$educ[allData$educ == 4] = 2

allData$educ <- factor(allData$educ)
levels(allData$educ) <- c(1:4)
saveRDS(allData, "~/Google Drive/CodeProjects/R/allData.rds")
saveRDS(xState, "~/Google Drive/CodeProjects/R/xState.rds")
saveRDS(zState, "~/Google Drive/CodeProjects/R/zState.rds")




