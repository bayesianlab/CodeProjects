source('~/CodeProjects/R/kowData.R')
KOWchange <- (KOWpercent[2:54,] - KOWpercent[1:53,])
na <- seq(1,9,by=3)
OCEAN = seq(10,15, by=3)
LA = seq(16,69, by=3)
EUR = seq(70,123, by=3)
AFRICA = seq(124,144,by=3)
ASIADEVELOP = seq(145,162, by =3)
ASIA = seq(163,180,by=3)


which.min(KOWpercent$rgdpnaUSA)
rownames(KOWchange) <- 1962:2014
KOWpercent<- 100*KOWpercent
rec_years <- as.character(c(1974, 1980,1982,1991,2001,2009))

KOWchange[rec_years, 'rgdpnaUSA']

rbind(KOWchange[rec_years, 'rgdpnaUSA'],
      apply(KOWchange[rec_years,na],1,median),
      apply(KOWchange[rec_years,OCEAN], 1, median),
      apply(KOWchange[rec_years,LA], 1, median),
      apply(KOWchange[rec_years,EUR], 1, median),
      apply(KOWchange[rec_years,AFRICA], 1, median),
      apply(KOWchange[rec_years,ASIADEVELOP], 1, median),
      apply(KOWchange[rec_years,ASIA], 1, median)
      )
