homeDirectory <- '/Users/dillonflannery-valadez/Google Drive/CodeProjects/R/Rprojects/finalproject/HAL/'
source('/Users/dillonflannery-valadez/Google Drive/CodeProjects/R/Rprojects/finalproject/HAL/finalproject_functions.R')
source('/Users/dillonflannery-valadez/Google Drive/CodeProjects/R/Rprojects/finalproject/HAL/load_libraries.R')
fds <- readRDS("/Users/dillonflannery-valadez/Google Drive/CodeProjects/R/Rprojects/finalproject/project_data/fds.rds")

# Goal of this script is to run a hierarchical linear model with cruise day as a random slope. 

# lmer has randomness, and sample selection. 
# set seed in random number generator for consistent results 
set.seed(2.5)
nRows <- floor(.8*nrow(fds))
sampleRows <- sample(1:nrow(fds), nRows)
fdsSample <- fds[sampleRows, ]
fdsValidation <- fds[-sampleRows, ]

# Hierarchical lm 
shorexHierarchicalF <- dailyShorex ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
barHierarchicalF <- dailyBar ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
retailHierarchicalF <- dailyRetail ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
photoHierarchicalF <-  dailyPhoto ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
spaHierarchicalF <- dailySpa ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
casinoHierarchicalF <- dailyCasino ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
commHierarchicalF <- dailyComm ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)
miscHierarchicalF <- dailyMisc ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER  + 
  (1 + CRUISELENGTH | TRADE)

# shorexHier <- lmer(shorexHierarchicalF , data=fdsSample, REML=FALSE)
# barHier <- lmer(barHierarchicalF , data=fdsSample, REML=FALSE)
# retailHier <- lmer(retailHierarchicalF , data=fdsSample, REML=FALSE)
# photoHier <- lmer(photoHierarchicalF , data=fdsSample, REML=FALSE)
# spaHier <- lmer(spaHierarchicalF , data=fdsSample, REML=FALSE)
# casinoHier <- lmer(casinoHierarchicalF , data=fdsSample, REML=FALSE)
# commHier <- lmer(commHierarchicalF , data=fdsSample, REML=FALSE)
# miscHier <- lmer(miscHierarchicalF , data=fdsSample, REML=FALSE)
# saveModel(homeDirectory, shorexHier)
# saveModel(homeDirectory, barHier)
# saveModel(homeDirectory, retailHier)
# saveModel(homeDirectory, photoHier)
# saveModel(homeDirectory, spaHier)
# saveModel(homeDirectory, casinoHier)
# saveModel(homeDirectory, commHier)
# saveModel(homeDirectory, miscHier)

shorexHier <- readRDS(file=paste(homeDirectory,"shorexHier_PCD.rds", sep=''))
retailHier <- readRDS(file=paste(homeDirectory, "retailHier.rds", sep=''))
barHier <- readRDS(file=paste(homeDirectory, 'barHier.rds', sep =''))
photoHier <- readRDS(file=paste(homeDirectory, 'photoHier.rds', sep=''))
spaHier <- readRDS(file=paste(homeDirectory, 'spaHier.rds', sep=''))
casinoHier <- readRDS(file=paste(homeDirectory, 'casinoHier.rds', sep=''))
miscHier <- readRDS(file=paste(homeDirectory, 'miscHier.rds', sep=''))
commHier <- readRDS(file=paste(homeDirectory,'commHier.rds', sep=''))

shorex_hierarchical_coefs <- coef(shorexHier)[[1]]
retailHcoefs <- coef(retailHier)[[1]]
barHcoefs <- coef(barHier)[[1]]
photoHcoefs <- coef(photoHier)[[1]]
spaHcoefs <- coef(spaHier)[[1]]
casinoHcoefs <- coef(casinoHier)[[1]]
miscHcoefs <- coef(miscHier)[[1]]
commHcoefs <- coef(commHier)[[1]]

shorexHier


# Linear model
shorexF <- dailyShorex ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
shorexlm <- lm(shorexF, data= fdsSample)

barF <- dailyBar ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
barlm <- lm(barF, data= fdsSample)

retailF <- dailyRetail ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
retaillm <- lm(retailF, data= fdsSample)

photoF <- dailyPhoto ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
photolm <- lm(photoF, data= fdsSample)

spaF <- dailySpa ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
spalm <- lm(spaF, data=fdsSample)

miscF <- dailyMisc ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
misclm <- lm(miscF, data=fdsSample)

commF <- dailyComm ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
commlm <- lm(commF, data=fdsSample)
commlm$coefficients

casinoF <- dailyCasino ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
casinolm <- lm(casinoF, data=fdsSample)


# "ALASKA"  "ARABIA AFRICA" "ASIA ORIENT" "BERMUDA"  "CANADA NEW ENGLAND"
# "CARIBBEAN" "COASTAL" "EUROPE" "HAWAII" "MEXICO"            
# "PANAMA CANAL" "SOUTH AMERICA" "SOUTH PACIFIC" "WORLD VOYAGE"  

# Hierarchical model dataset for prediction
dummies <- cbind(dummy(fdsValidation$SHIPNAME)[,-1], dummy(fdsValidation$NATIONALITY)[,-1],
                 dummy(fdsValidation$X_META)[,-1],dummy(fdsValidation$PAX_LOYALTY)[,-1],
                 dummy(fdsValidation$PAX_GENDER)[,-1])
continuous <- cbind(fdsValidation$NTR_PCD, fdsValidation$PAX_AGE,
                    fdsValidation$BOOK_TO_CRUISE_TIME_DIFF, fdsValidation$CRUISELENGTH)
hierarchicalX <- cbind(rep(1,nrow(continuous)), continuous, dummies)

# Linear model dataset for prediction
dummies <- cbind(dummy(fdsValidation$SHIPNAME)[,-1],
                 dummy(fdsValidation$TRADE)[,-1],
                 dummy(fdsValidation$NATIONALITY)[,-1],
                 dummy(fdsValidation$X_META)[,-1], 
                 dummy(fdsValidation$PAX_LOYALTY)[,-1],
                 dummy(fdsValidation$PAX_GENDER)[,-1])
linearX <- cbind(rep(1, nrow(continuous)), continuous, dummies)

rMSEShorex <- rootMSE(fdsValidation, shorex_hierarchical_coefs, shorexlm$coefficients,
                hierarchicalX, linearX, 'dailyShorex')
rMSERetail <- rootMSE(fdsValidation, retailHcoefs, retaillm$coefficients,
                      hierarchicalX, linearX, 'dailyRetail')
rMSEBar <- rootMSE(fdsValidation, barHcoefs, barlm$coefficients,
                   hierarchicalX, linearX, 'dailyBar')
rMSEPhoto <- rootMSE(fdsValidation, photoHcoefs, photolm$coefficients,
                     hierarchicalX, linearX, 'dailyPhoto')
rMSESpa <- rootMSE(fdsValidation, spaHcoefs, spalm$coefficients,
                   hierarchicalX, linearX, 'dailySpa')
rMSECasino <- rootMSE(fdsValidation, casinoHcoefs, casinolm$coefficients,
                      hierarchicalX, linearX, 'dailyCasino')
rMSEMisc <- rootMSE(fdsValidation, miscHcoefs, misclm$coefficients,
                    hierarchicalX, linearX, 'dailyMisc')
rMSEComm <- rootMSE(fdsValidation, commHcoefs, commlm$coefficients,
                    hierarchicalX, linearX, 'dailyComm')


rMSEShorex[[1]]
rMSERetail[[1]]
rMSEBar[[1]]
rMSEPhoto[[1]]
rMSESpa[[1]]
rMSECasino[[1]]
rMSEMisc[[1]]
rMSEComm[[1]]

shorexHier
shorex_hierarchical_coefs
