source('~/Coding/R/Rprojects/finalproject/HAL/finalproject_functions.R')
fds <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/fds.rds")
predictionData <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/predictionData.rds")
predictionDataH <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/hierarchicalMat.rds")

set.seed(2.5)
rows <- sample(1:nrow(fds), 200000)
fdsSample <- fds[rows, ]
# Hierarchical lm 
shorexHierarchicalF <- dailyShorex ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + NTR_PCD | TRADE)
barHierarchicalF <- dailyBar ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + NTR_PCD | TRADE)
retailHierarchicalF <- dailyRetail ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + NTR_PCD | TRADE)
# There is a saved file of this result with 200,000 obs. 
shorexH <- readRDS("~/shorexH200000obs.rds")
barH <- lmer(barHierarchicalF , data=fdsSample, REML=FALSE)
retailH <- lmer(retailHierarchicalF , data=fdsSample, REML=FALSE)
hierCoefs <- coef(shorexH)
hierCoefsB <- coef(barH)
hierCoefsR <- coef(retailH)


# Linear lm
shorexF <- dailyShorex ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
shorexlm <- lm(shorexF, data= fdsSample)
barF <- dailyBar ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
barlm <- lm(barF, data= fdsSample)
retailF <- dailyRetail ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
retaillm <- lm(retailF, data= fdsSample)

alaskaCoefs <- hierCoefs[[1]][1,]
arabAfricaCoefs <- hierCoefs[[1]][2,]
asiaOrientCoefs <- hierCoefs[[1]][3,]
bermudaCoefs <- hierCoefs[[1]][4,]
canadaCoefs <- hierCoefs[[1]][5,]
caribbeanCoefs <- hierCoefs[[1]][6,]
costalCoefs <- hierCoefs[[1]][7,]
europeCoefs <- hierCoefs[[1]][8,]
hawaiiCoefs <- hierCoefs[[1]][9,]
mexicoCoefs <- hierCoefs[[1]][10,]
panamaCoefs <- hierCoefs[[1]][11,]
southAmericaCoefs <- hierCoefs[[1]][12,]
southPacificCoefs <- hierCoefs[[1]][13,]
worldVoyCoefs <- hierCoefs[[1]][14,]

alaskaCoefsB <- hierCoefsB[[1]][1,]
arabAfricaCoefsB <- hierCoefsB[[1]][2,]
asiaOrientCoefsB <- hierCoefsB[[1]][3,]
bermudaCoefsB <- hierCoefsB[[1]][4,]
canadaCoefsB <- hierCoefsB[[1]][5,]
caribbeanCoefsB <- hierCoefsB[[1]][6,]
costalCoefsB <- hierCoefsB[[1]][7,]
europeCoefsB <- hierCoefsB[[1]][8,]
hawaiiCoefsB <- hierCoefsB[[1]][9,]
mexicoCoefsB <- hierCoefsB[[1]][10,]
panamaCoefsB <- hierCoefsB[[1]][11,]
southAmericaCoefsB <- hierCoefsB[[1]][12,]
southPacificCoefsB <- hierCoefsB[[1]][13,]
worldVoyCoefsB <- hierCoefsB[[1]][14,]


alaskaCoefsR <- hierCoefsR[[1]][1,]
arabAfricaCoefsR <- hierCoefsR[[1]][2,]
asiaOrientCoefsR <- hierCoefsR[[1]][3,]
bermudaCoefsR <- hierCoefsR[[1]][4,]
canadaCoefsR <- hierCoefsR[[1]][5,]
caribbeanCoefsR <- hierCoefsR[[1]][6,]
costalCoefsR <- hierCoefsR[[1]][7,]
europeCoefsR <- hierCoefsR[[1]][8,]
hawaiiCoefsR <- hierCoefsR[[1]][9,]
mexicoCoefsR <- hierCoefsR[[1]][10,]
panamaCoefsR <- hierCoefsR[[1]][11,]
southAmericaCoefsR <- hierCoefsR[[1]][12,]
southPacificCoefsR <- hierCoefsR[[1]][13,]
worldVoyCoefsR <- hierCoefsR[[1]][14,]



# Alaska analysis
alaskaResults <- calcRelativeErrs(fds, predictionData, predictionDataH, shorexlm, 
                      alaskaCoefs, "ALASKA")
ggplot(alaskaResults, aes(x=Hierarchical)) + geom_histogram(bins=30, colour="red", fill="black")
ggplot(alaskaResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
nrow(alaskaResults)
summary(alaskaResults$Hierarchical)
summary(alaskaResults$lm)

alaskaBarResults <- calcRelativeErrs(fds, predicionData, predictionDataH, barlm,
                                     alaskaCoefsB, "ALASKA", "BAR_REV")
ggplot(alaskaBarResults, aes(x=Hierarchical)) + geom_histogram(bins=30, colour="red", fill="black")
ggplot(alaskaBarResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(alaskaBarResults$Hierarchical)
summary(alaskaBarResults$lm)

alaskaRetailResults <- calcRelativeErrs(fds, predictionData, predictionDataH, retaillm,
                                        alaskaCoefsR, "ALASKA", "RETAIL_REV")
ggplot(alaskaRetailResults, aes(x=Hierarchical)) + geom_histogram(bins=30, colour="red", fill="black")
ggplot(alaskaRetailResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(alaskaRetailResults$Hierarchical)
summary(alaskaRetailResults$lm)
# Asia orient
asiaOrientResults <- calcRelativeErrs(fds, predictionData, predictionDataH, shorexlm, 
                                      asiaOrientCoefs, "ASIA ORIENT")
ggplot(data=asiaOrientResults, aes(x=Hierarchical)) + geom_histogram(bins=10, colour="red", fill="black")
ggplot(data=asiaOrientResults, aes(x=lm)) + geom_histogram(bins=10, colour="blue")
summary(asiaOrientResults$Hierarchical)
summary(asiaOrientResults$lm)
max(asiaOrientResults$Hierarchical) - min(asiaOrientResults$Hierarchical)
max(asiaOrientResults$lm) - min(asiaOrientResults$lm)


# Canada
canadaResults <- calcRelativeErrs(fds, predictionData, predictionDataH, shorexlm, 
                                  canadaCoefs, "CANADA NEW ENGLAND")
ggplot(data=canadaResults, aes(x=Hierarchical)) + geom_histogram(bins=10, colour="red", fill="black")
ggplot(data=canadaResults, aes(x=lm)) + geom_histogram(bins=10, colour="blue")
summary(canadaResults$Hierarchical)
summary(canadaResults$lm)

canadaBarResults <- calcRelativeErrs(fds, predictionData, predictionDataH, barlm,
                                     canadaCoefsB, "CANADA NEW ENGLAND", "BAR_REV")
ggplot(data=canadaBarResults, aes(x=Hierarchical)) + geom_histogram(bins=20, colour="red", fill="black")
ggplot(data=canadaBarResults, aes(x=lm)) + geom_histogram(bins=20, colour="blue")
summary(canadaBarResults$Hierarchical)
summary(canadaBarResults$lm)

canadaRetailResults <- calcRelativeErrs(fds, predictionData, predictionDataH, retaillm,
                                     canadaCoefsR, "CANADA NEW ENGLAND", "RETAIL_REV")

canadaRetailResults <- canadaRetailResults[-22, ]
ggplot(data=canadaRetailResults, aes(x=Hierarchical)) + 
  geom_histogram(bins=20, colour="red", fill="black")
ggplot(data=canadaRetailResults, aes(x=lm)) + geom_histogram(bins=20, colour="blue")
summary(canadaRetailResults$Hierarchical)
summary(canadaRetailResults$lm)

# Caribbean 
caribbeanResults <-calcRelativeErrs(fds, predictionData, predictionDataH, shorexlm,
                                    caribbeanCoefs, "CARIBBEAN")

ggplot(data=caribbeanResults, aes(x=Hierarchical)) + geom_histogram(bins=30, colour="red", fill="black")
ggplot(data=caribbeanResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(caribbeanResults$Hierarchical)
summary(caribbeanResults$lm)

caribbeanBarResults <- calcRelativeErrs(fds, predictionData, predictionDataH, barlm,
                                        caribbeanCoefsB, "CARIBBEAN", "BAR_REV")
ggplot(data=caribbeanBarResults, aes(x=Hierarchical)) + 
  geom_histogram(bins=30, colour="red", fill="black")
ggplot(data=caribbeanBarResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(caribbeanBarResults$Hierarchical)
summary(caribbeanBarResults$lm)

caribbeanRetailResults <- calcRelativeErrs(fds, predictionData, predictionDataH, retaillm,
                                        caribbeanCoefsR, "CARIBBEAN", "RETAIL_REV")
ggplot(data=caribbeanRetailResults, aes(x=Hierarchical)) + 
  geom_histogram(bins=30, colour="red", fill="black")
ggplot(data=caribbeanRetailResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(caribbeanRetailResults$Hierarchical)
summary(caribbeanRetailResults$lm)

# Europe
europeResults <-calcRelativeErrs(fds, predictionData, predictionDataH, shorexlm,
                                    europeCoefs, "EUROPE", "SHOREX_REV")
ggplot(data=europeResults, aes(x=Hierarchical)) + geom_histogram(bins=10, colour="red", fill="black")
ggplot(data=europeResults, aes(x=lm)) + geom_histogram(bins=10, colour="blue")
summary(europeResults$Hierarchical)
summary(europeResults$lm)

europeBarResults <- calcRelativeErrs(fds, predictionData, predictionDataH, barlm,
                                     europeCoefsB, "EUROPE", "BAR_REV")
ggplot(data=europeBarResults, aes(x=Hierarchical)) + geom_histogram(bins=30, colour="red", fill="black")
ggplot(data=europeBarResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(europeBarResults$Hierarchical)
summary(europeBarResults$lm)

europeRetailResults <- calcRelativeErrs(fds, predictionData, predictionDataH, retaillm,
                                     europeCoefsR, "EUROPE", "RETAIL_REV")
ggplot(data=europeRetailResults, aes(x=Hierarchical)) + 
  geom_histogram(bins=30, colour="red", fill="black")
ggplot(data=europeRetailResults, aes(x=lm)) + geom_histogram(bins=30, colour="blue")
summary(europeRetailResults$Hierarchical)
summary(europeRetailResults$lm)
