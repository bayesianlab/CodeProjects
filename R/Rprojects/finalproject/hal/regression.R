usobservations <- completeData[completeData$NATIONALITY == "UNITED STATES", ]
# ports per state
# alaska 3
# ca 2
# mass 1 
# florida 2
# hawaii 1
# new york 1
# washington 1



# trade 12 levels 
# Income 8 levels
# X_meta 5 levels
# Nationality 112 levels

# Three day reg
threedayFormula <- onBoardDailySpend ~ NTR + TRADE + PAX_AGE +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME
lm3 <- lm(threedayFormula, data=threeDay)
summary(lm3)
length(lm3$coefficients)
# Priors
fullb0 <- rep(0, 22)
fullB0 <- rep(.001, 22)
full <- MCMCregress(threedayFormula, data=threeDay, b0=fullb0, B0=fullB0, 
                    c0=10,d0=100, marginal.likelihood="Chib95")
rThreeDayFormula <- onBoardDailySpend ~  PAX_LOYALTY + EGSS_OVERALL
rb0 <- rep(0, 6)
rB0 <- rep(.001, 6)
restrict <- MCMCregress(rThreeDayFormula, data=threeDay, b0=rb0, B0=rB0, 
                    marginal.likelihood="Chib95")
b <- BayesFactor(full, restrict)
print(b)

# Seven Day reg
sevendayFormula <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME
noinc <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL 
noinc_noegss <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
  NATIONALITY + X_META
noinc_noegss_nometa <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
  NATIONALITY
noinc_noegss_nometa_nonation <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE
nometa <- onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
  NATIONALITY  + EGSS_OVERALL + INCOME
nonation7 <-onBoardDailySpend ~ NTR + SHIPNAME + TRADE + PAX_AGE +
   X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME

lm7 <- lm(sevendayFormula, data=sevenDay)
noinc7 <- lm(noinc, data=sevenDay)
noinc_noegss7 <- lm(noinc_noegss, data=sevenDay)
noinc_noegss_nometa7 <- lm(noinc_noegss_nometa, data=sevenDay)
noinc_noegss_nometa_nonation7 <- lm(noinc_noegss_nometa_nonation, data=sevenDay)
nometalm7 <- lm(nometa, data=sevenDay)
nonation7 <- lm(nonation7, data=sevenDay)

summary(lm7)
length(lm7$coefficients)
length(noinc7$coefficients)
length(noinc_noegss7$coefficients)
length(noinc_noegss_nometa7$coefficients)
length(noinc_noegss_nometa_nonation7$coefficients)
length(nometalm7$coefficients)
length(nonation7$coefficients)

fullb0 <- rep(0, 40)
fullB0 <- rep(.001, 40)
noincb0 <- rep(0, length(noinc7$coefficients))
noincB0 <- rep(0.001, length(noinc7$coefficients))
noinc_noegssb0 <- rep(0, length(noinc_noegss7$coefficients))
noinc_noegssB0 <- rep(0.001, length(noinc_noegss7$coefficients))
noinc_noegss_nometab0 <- rep(0, length(noinc_noegss_nometa7$coefficients))
noinc_noegss_nometaB0 <- rep(0.001, length(noinc_noegss_nometa7$coefficients))
nometab0 <- rep(0, length(nometalm7$coefficients))
nometaB0 <- rep(.001, length(nometalm7$coefficients))
nonatb0 <- rep(0, length(nonation7$coefficients))
nonatB0 <- rep(0.001, length(nonation7$coefficients))

full <- MCMCregress(sevendayFormula, data=sevenDay, b0=fullb0, B0=fullB0,
                    marginal.likelihood = "Chib95")
noincm <- MCMCregress(noinc, data=sevenDay, b0=noincb0, B0=noincB0, 
                      marginal.likelihood = "Chib95")
noinc_noegssm <- MCMCregress(noinc_noegss, data=sevenDay, b0=noinc_noegssb0, 
                             B0=noinc_noegssB0, marginal.likelihood = "Chib95")
noinc_noegss_nometam <- MCMCregress(noinc_noegss_nometa, data=sevenDay, b0=noinc_noegss_nometab0,
                                    B0=noinc_noegss_nometaB0, marginal.likelihood="Chib95")
nometam <- MCMCregress(nometa, data=sevenDay, b0=nometab0, B0=nometaB0,
                         marginal.likelihood = "Chib95")
nonation7m <- MCMCregress(nonation7, data=sevenDay, b0=nonatb0, B0=nonatB0,
                          marginal.likelihood = "Chib95")
nullm <- MCMCregress(onBoardDailySpend ~ 1, data=sevenDay, b0=0, B0= .001, 
                     marginal.likelihood = "Chib95")
BayesFactor(full, noincm, noinc_noegssm, noinc_noegss_nometam, nullm)
summary(full)
# twelve day reg
twelvedayF <- onBoardDailySpend ~ NTR + SHIPNAME + PAX_AGE +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME
ticketNation <- onBoardDailySpend ~ NTR + NATIONALITY  
null <- onBoardDailySpend ~ 1
ticket_nation_age_egss <- onBoardDailySpend ~ NTR + NATIONALITY + PAX_AGE + EGSS_OVERALL
noMeta <- onBoardDailySpend ~ NTR + SHIPNAME + PAX_AGE +
  NATIONALITY + PAX_LOYALTY + EGSS_OVERALL + INCOME

lm12 <- lm(twelvedayF, data=twelveDay)
summary(lm12)

tnlm12 <- lm(ticketNation, data=twelveDay)
nulllm12 <- lm(null, data=twelveDay)
tnaelm12 <- lm(ticket_nation_age_egss, data=twelveDay)
nometalm <- lm(noMeta, data=twelveDay)
length(lm12$coefficients)
length(tnlm12$coefficients)
length(nulllm12$coefficients)
length(tnaelm12$coefficients)
length(nometalm$coefficients)
fullb0 <- rep(0, 29)
fullB0 <- rep(.001, 29)

rb0 <- rep(0, length(tnlm12$coefficients))
rB0 <- rep(.001, length(tnlm12$coefficients))

nullb0 <- rep(0,1)
nullB0 <- rep(.001,1)

tnaeb0 <- rep(0,9)
tnaeB0 <- rep(0.001,9)

nometab0 <- rep(0, 25)
nometaB0 <- rep(.001, 25)

full <- MCMCregress(twelvedayF, data=twelveDay, b0=fullb0, B0=fullB0,
                    marginal.likelihood = "Chib95")
ticketNation <- MCMCregress(ticketNation, data=twelveDay, b0=rb0, B0=rB0,
                   marginal.likelihood = "Chib95")
null12 <- MCMCregress(null, data=twelveDay, b0=nullb0, B0=nullB0,
                   marginal.likelihood = "Chib95")
tnae <- MCMCregress(ticket_nation_age_egss, data=twelveDay, b0=tnaeb0, B0=tnaeB0,
                        marginal.likelihood="Chib95")
nometaB <- MCMCregress(noMeta, data=twelveDay, b0=nometab0, B0=nometaB0, 
                       marginal.likelihood= "Chib95")
BayesFactor(full, ticketNation,tnae, nometaB, null12)

# 14 day
fourteenDay$TRADE <- factor(fourteenDay$TRADE)
table(fourteenDay$TRADE)
fourteendayF <- onBoardDailySpend ~ NTR  + SHIPNAME + PAX_AGE + NATIONALITY + X_META + 
  PAX_LOYALTY + EGSS_OVERALL  + INCOME
noloyalty <- onBoardDailySpend ~ NTR  + SHIPNAME + PAX_AGE + NATIONALITY + X_META + 
  EGSS_OVERALL  + INCOME
noloynonation <- onBoardDailySpend ~ NTR  + SHIPNAME + PAX_AGE + X_META + 
  EGSS_OVERALL  + INCOME
dumb <- onBoardDailySpend ~ 1

lm14 <- lm(fourteendayF, data=fourteenDay)
rlm14 <- lm(noloyalty, data = fourteenDay)
rrlm14 <- lm(noloynonation, data=fourteenDay)
summary(lm14)
length(lm14$coefficients)
length(rlm14$coefficients)
length(rrlm14$coefficients)

fullb0 <- rep(0, 32)
fullB0 <- rep(0.001, 32)

rb0 <- rep(0,26)
rB0 <- rep(.001, 26)

rrb0 <- rep(0,21)
rrB0 <- rep(0.001,21)

dumbb0 <- rep(0,2)
dumbB0 <- rep(.001,2)
full <- MCMCregress(fourteendayF, data= fourteenDay, b0=fullb0, B0 =fullB0, 
                    marginal.likelihood="Chib95")
r14 <- MCMCregress(noloyalty, data= fourteenDay, b0=rb0, B0=rB0,
                   marginal.likelihood = "Chib95")
rr14 <- MCMCregress(noloynonation, data=fourteenDay, b0=rrb0, B0 =rrB0,
                    marginal.likelihood = "Chib95")
d14 <- MCMCregress(dumb, data=fourteenDay, b0=dumbb0, B0=dumbB0,
                   marginal.likelihood= "Chib95")
BayesFactor(full, r14, rr14, d14)


# twenty six day reg
twentysixdayF <- onBoardDailySpend ~ NTR  + PAX_AGE + NATIONALITY + X_META + 
  PAX_LOYALTY + EGSS_OVERALL + INCOME
noinc26 <- onBoardDailySpend ~ NTR + SHIPNAME + PAX_AGE +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL 
lm26 <- lm(twentysixdayF, data=twentysixDay)
summary(lm26)

# one hundred sixteen day
f116 <- onBoardDailySpend ~ NTR  + PAX_AGE + NATIONALITY + X_META + 
  PAX_LOYALTY + EGSS_OVERALL + INCOME
lm116 <- lm(f116, data=onehundredsixteenDay)
summary(lm116)
