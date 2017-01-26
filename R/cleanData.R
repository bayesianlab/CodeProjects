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

dataFiles <- "/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/GelmanPaper/"
may19_2003 <- read.spss(paste(dataFiles, 'may19_2003.por', sep =''), to.data.frame = TRUE)

may19_2003 <- subset(may19_2003, select = c( WTFCTR, RACE, STATE, D3, D2, S3, Q13 ))
may5 <- read.spss(paste(dataFiles, 'may6_2006.por', sep =''), to.data.frame = TRUE)
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