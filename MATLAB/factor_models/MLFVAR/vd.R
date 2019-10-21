library(readr)
library(ggplot2)
library(reshape2)
library(ggsci)
vdend <- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/vdend", col_names=FALSE)
vdbeg <- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/vdbeg", col_names=FALSE)
NAM = seq(1,9)
NAOUT = seq(1,9, by = 3)
NACONS = seq(2,8,by=3) 
NAINV = seq(3,7,by=3)
OCEAN = seq(10,15)
OCEANOUT = seq(10,15,by=3)
OCEANCONS = seq(11,14, by=3)
OCEANINV = seq(12,13,by=3)
LA = seq(16,69)
LAOUT = seq(16,69, by=3)
LACONS = seq(17,68, by=3)
LAINV = seq(18,67, by=3)
EUR = seq(70,123)
EUROUT = seq(70,123,by=3)
EURCONS = seq(71,122,by=3)
EURINV = seq(72,121,by=3)
AFRICA = seq(124,144)
AFRICAOUT = seq(124,144,by=3)
AFRICACONS = seq(125,143, by=3)
AFRICAINV = seq(126,142,by=3)
ASIADEVELOP = seq(145,162)
ASIADEVELOPOUT = seq(145,162, by=3)
ASIADEVELOPCONS = seq(146,161, by=3)
ASIADEVELOPINV = seq(147,160,by=3)
ASIA = seq(163,180)
ASIAOUT = seq(163,180,by=3)
ASIACONS = seq(164,179, by=3)
ASIAINV = seq(165,178)

vdbeg<-cbind(vdbeg,regions=c(rep('NRTH.AM.', 9),
                             rep('OCEAN', 6),
                             rep('LA', 54),
                             rep('EUR', 54),
                             rep('AFR', 21),
                             rep('ASIADEV', 18),
                             rep('ASIA', 18)),
             series=rep(c('Out', 'Cons','Inv'), 60))

vdend<-cbind(vdend,regions=c(rep('NRTH.AM.', 9),
                             rep('OCEAN', 6),
                             rep('LA', 54),
                             rep('EUR', 54),
                             rep('AFR', 21),
                             rep('ASIADEV', 18),
                             rep('ASIA', 18)),
             series=rep(c('Out', 'Cons','Inv'), 60))

colnames(vdbeg)[1:3] <- c("WB", "RB", "CB")
colnames(vdend)[1:3] <- c("WE", "RE", "CE")

both <- data.frame(cbind(vdbeg, vdend[,c(1,2,3)]))
bothlong <- melt(both)
subdata <- bothlong[(bothlong$variable == "RE" & (bothlong$series =="Out")),]
before <-by(subdata[subdata$variable=="RE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "RB" & (bothlong$series =="Out")),]
after <- by(subdata[subdata$variable=="RB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
out <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour= "black") +
  # scale_fill_discrete() + 
  theme_bw()+
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Output") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))
out

subdata <- bothlong[(bothlong$variable == "RE") & (bothlong$series =="Cons"),]
before <-by(subdata[subdata$variable=="RE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "RB") & (bothlong$series =="Cons"),]
after <- by(subdata[subdata$variable=="RB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
cons <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour="black") + theme_bw()+
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Consumption") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))
cons

subdata <- bothlong[(bothlong$variable == "RE") & (bothlong$series =="Inv"),]
before <-by(subdata[subdata$variable=="RE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "RB") & (bothlong$series =="Inv"),]
after <- by(subdata[subdata$variable=="RB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")

inv <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour="black") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme_bw()+
  labs(y="Average Variance Decomposition", x="Region")+
  ggtitle("Variance Decompositions for Investment") +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))

ggsave(paste("~/GoogleDrive/statespace/", "out_bar.jpeg", sep=""), out)
ggsave(paste("~/GoogleDrive/statespace/", "cons_bar.jpeg", sep=""), cons)
ggsave(paste("~/GoogleDrive/statespace/", "inv_bar.jpeg", sep=""), inv)

subdata <- bothlong[(bothlong$variable == "CE" & (bothlong$series =="Out")),]
before <-by(subdata[subdata$variable=="CE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "CB" & (bothlong$series =="Out")),]
after <- by(subdata[subdata$variable=="CB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
out <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge()) +
  # scale_fill_discrete() + 
  theme_bw()+
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Output") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))


subdata <- bothlong[(bothlong$variable == "CE") & (bothlong$series =="Cons"),]
before <-by(subdata[subdata$variable=="CE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "CB") & (bothlong$series =="Cons"),]
after <- by(subdata[subdata$variable=="CB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
cons <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour="black") +
  # scale_fill_discrete(name="Period", labels=c("1962-1992", "1992-2014")) + 
  theme_bw()+
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Consumption") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))
cons

subdata <- bothlong[(bothlong$variable == "CE") & (bothlong$series =="Inv"),]
before <-by(subdata[subdata$variable=="CE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "CB") & (bothlong$series =="Inv"),]
after <- by(subdata[subdata$variable=="CB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")

inv <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour="black") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  theme_bw()+
  labs(y="Average Variance Decomposition", x="Region")+
  ggtitle("Variance Decompositions for Investment") +
  theme(axis.text = element_text(size = 15)) +
  theme(axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(size=30)) + 
  theme(legend.title = element_text(size=20))+ 
  theme(legend.text = element_text( size=15))

ggsave(paste("~/GoogleDrive/statespace/", "out_country_bar.jpeg", sep=""), out)
ggsave(paste("~/GoogleDrive/statespace/", "cons_country_bar.jpeg", sep=""), cons)
ggsave(paste("~/GoogleDrive/statespace/", "inv_country_bar.jpeg", sep=""), inv)


varianceDecomp <- read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/varianceDecomp.csv", col_names=FALSE)
varianceDecomp <- 100*varianceDecomp


africadf <- data.frame(Name = c("Idiosyncratic", "World", "Region", "Country"),
              Africa=c(mean(varianceDecomp[AFRICA,1]), mean(varianceDecomp[AFRICA,2]),
              mean(varianceDecomp[AFRICA,3]),mean(varianceDecomp[AFRICA,4])),
              Asia=c(mean(varianceDecomp[ASIA,1]), mean(varianceDecomp[ASIA,2]),
                     mean(varianceDecomp[ASIA,3]),mean(varianceDecomp[ASIA,4])),
              "Developing Asia"=c(mean(varianceDecomp[ASIADEVELOP,1]), mean(varianceDecomp[ASIADEVELOP,2]),
                               mean(varianceDecomp[ASIADEVELOP,3]),mean(varianceDecomp[ASIADEVELOP,4])),
              Europe=c(mean(varianceDecomp[EUR,1]), mean(varianceDecomp[EUR,2]),
                       mean(varianceDecomp[EUR,3]),mean(varianceDecomp[EUR,4])),
              "L.A."=c(mean(varianceDecomp[LA,1]), mean(varianceDecomp[LA,2]),
                   mean(varianceDecomp[LA,3]),mean(varianceDecomp[LA,4])),
              "N.A."=c(mean(varianceDecomp[NAM,1]), mean(varianceDecomp[NAM,2]),
                  mean(varianceDecomp[NAM,3]),mean(varianceDecomp[NAM,4])),
              Ocean=c(mean(varianceDecomp[OCEAN,1]), mean(varianceDecomp[OCEAN,2]),
                      mean(varianceDecomp[OCEAN,3]),mean(varianceDecomp[OCEAN,4])))
africadflong <- melt(africadf)

africadflong$Name <- relevel(africadflong$Name, ref="Idiosyncratic")

ggplot(data=africadflong) + geom_bar(aes(x = variable, y = value, fill=Name),
           stat="identity",position=position_dodge(), 
           colour="black") + theme_bw()+ labs(y="Average Variance Decomposition", x="Region")+
  scale_fill_aaas() +
  ggtitle("Variance Decompositions Across Regions") +
  theme(axis.text = element_text(size = 8)) +
  theme(axis.title = element_text(size = 15)) +
  theme(plot.title = element_text(size=20)) + 
  theme(legend.title = element_text(size=15))+ 
  theme(legend.text = element_text( size=15)) +
  theme(legend.title = element_blank())
