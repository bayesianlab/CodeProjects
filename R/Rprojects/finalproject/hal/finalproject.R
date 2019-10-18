source('~/CodeProjects/R/Rprojects/finalproject/hal/data_loading.R')

# US Heatmap
# Removes background
no_back <-
  theme(
    axis.text = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank()
  )

usa_base <- ggplot(data = freqState, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_fixed(1.3)

usa_heatmap <-
  usa_base + geom_polygon(data = freqState, aes(fill = freq), color = "white") +
  geom_polygon(color = "black", fill = NA)  + no_back +
  # scale_fill_gradient("Number of Guests",low="steelblue1", high="orangered") +
  # scale_fill_gradient("Number of Guests",low="steelblue1", high="orangered", 
  # trans="log10") +
  scale_fill_gradientn(
    "Number Of Guests",
    colours=rev(rainbow(6)),
    trans="log10"
  ) +
  # scale_fill_gradient(
  #   name = "Frequency",
  #   trans = "log10",
  #   low = "blue",
  #   high = "red"
  # ) +
  geom_text(
    check_overlap = TRUE,
    data = freqState,
    aes(Longitude, Latitude, label = STATE_CODE),
    size = 3,
    color = "white",
    fontface = "bold"
  )  #+ theme(panel.background = element_rect(fill=""))

usa_heatmap
sumStates[order(-sumStates$freq),]

# USA Dot plot 
usadots <- ggplot() + borders("world", xlim= c(-180,-50), ylim= c(15, 90), fill="grey30", colour="white" ) + 
  no_back + 
  geom_count(aes(stateLatLon$Longitude, stateLatLon$Latitude), alpha=.5, color="red") +
  scale_size_continuous(name="Number of Guests", range = c(1,25)) +
  theme(panel.background = element_rect(fill="grey87"), legend.key=element_rect(fill="grey30"))

usadots  

# Creates a map of the world
mapo <- borders("world", fill="grey30", colour="white")
world <- ggplot() + mapo +
  geom_count(
    aes(datWlatlon$Longitude, datWlatlon$Latitude),
    alpha = .5,
    color = "red"
  ) +
  scale_size_continuous(name = "Number of Guests", range = c(1, 30))  +
  no_back + theme(panel.background=element_rect(fill="royalblue"), legend.key=element_rect(fill="grey30"))
world

head(summary(datWlatlon$NATIONALITY))

# Income Plot Comparing Imputed Data to Original
inc <- finaldat[!is.na(finaldat$INCOME),]
nonImputeGG <- ggplot(inc, aes(INCOME))
imputeGG <- ggplot(completeData, aes(INCOME))
p1 <- nonImputeGG + geom_bar(aes(fill=INCOME)) + 
  labs(title="Non-Imputed Data") + 
  theme(axis.text.x=element_text(angle=45))
p2 <- imputeGG + geom_bar(aes(fill=INCOME)) + 
  labs(title="Imputed Data") + theme(axis.text.x=element_text(angle=45))
p1
p2

# Age and total spend per day
g1 <- ggplot(finaldat, aes(PAX_AGE, totalSpendPerDay))
a1 <- g1 + geom_jitter(alpha=.2) +
  labs(x="Age", y="Spending Per Day") 
a1

# High Rating plot
onlyGaveEGSS_Overall_Review <-
  finaldat[!is.na(finaldat$EGSS_OVERALL), ]
onlyGaveEGSS_Overall_Review$EGSS_OVERALL <-
  factor(onlyGaveEGSS_Overall_Review$EGSS_OVERALL)
egssGG <-
  ggplot(onlyGaveEGSS_Overall_Review,
         aes(EGSS_OVERALL, onBoardDailySpend))
satisfactionPlot <-
  egssGG + geom_jitter(aes(colour = EGSS_OVERALL)) + theme_dark() +
  labs(colour = "Customer Satisfaction", x = "Customer\nSatisfaction", y =
         "On Board Spending")
satisfactionPlot

aggregate(finaldat[, c("onBoardDailySpend")], by=list(finaldat$EGSS_OVERALL), mean)

# Destination and Spending Plot 
tradeSpendPlot <- ggplot(finaldat, aes(finaldat$onBoardDailySpend, finaldat$TRADE)) +
  geom_jitter(aes(colour = finaldat$TRADE), alpha = .5) +
  labs(colour = "Destination", x = "On Board Spending", y = "Desination") +
  theme_dark()
tradeSpendPlot
tradeSpend <-
  aggregate(finaldat[, c("onBoardDailySpend")], by = list(finaldat$TRADE), mean)
tradeSpend

# On Board Spending By  Cruise Length
finaldatCopy <- finaldat
finaldatCopy$CRUISELENGTH <- factor(finaldatCopy$CRUISELENGTH)
finaldatCopy$CRUISELENGTH <- combineLevels(finaldatCopy$CRUISELENGTH, c('3', '7', '8', '9'), '3-9 Days')
finaldatCopy$CRUISELENGTH <- combineLevels(finaldatCopy$CRUISELENGTH, 
                                           c('10', '11', '12', '13', '14',
                                            '15', '16', '17', '18', '18', '19', '20'),
                                           '10-20 Days')
finaldatCopy$CRUISELENGTH <- combineLevels(finaldatCopy$CRUISELENGTH, 
                                           c('22', '26', '32', '35', '42', '47', '49', '50', 
                                             '78', '115', '116'),
                                           '22-116 Days')

summaryDaySpendCruiseLen <- aggregate(finaldatCopy[,c("onBoardDailySpend")], 
                                      by=list(finaldatCopy$CRUISELENGTH), mean)
crLenBar <- ggplot(summaryDaySpendCruiseLen, aes(Group.1, x, fill= Group.1)) + 
  geom_bar(stat="identity", width =.35) +
  labs(x="Cruise Length", y="Average On Board Spending", fill = "Cruise Length")
crLenBar
summaryDaySpendCruiseLen

# NTR and On Board Spending
senseiData <- finaldat[(finaldat$onBoardDailySpend > 0), ]
senseiData <- senseiData[senseiData$NTR >0 ,]
ntr_spendOnBoardGG <- ggplot(finaldat, aes(NTR, onBoardDailySpend))
ntr_spendOnBoardJit <- geom_jitter(color="blue", size=1, alpha=.8)
ntr_spendOnBoardLabs <- labs( x="Net Ticket Rev.", y = "On Board Spending Per Day", 
                              color="Net Ticket Rev")
ntr_spendOnBoardGG + ntr_spendOnBoardJit  + ntr_spendOnBoardLabs



