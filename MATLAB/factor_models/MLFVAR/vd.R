library(readr)
library(ggplot2)
library(reshape2)
library(ggsci)

vdend <- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/vdend", col_names=FALSE)
vdbeg <- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/vdbeg", col_names=FALSE)
# vdupper<- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/varianceDecompUpper.csv", col_names=FALSE)
# vdlower<- 100*read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/varianceDecompLower.csv", col_names=FALSE)
sumOM <- read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/sumOM.csv", col_names=FALSE)


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
                             rep('L.A.', 54),
                             rep('EUR', 54),
                             rep('AFR', 21),
                             rep('DEV.ASIA', 18),
                             rep('ASIA', 18)),
             series=rep(c('Out', 'Cons','Inv'), 60))

vdend<-cbind(vdend,regions=c(rep('NRTH.AM.', 9),
                             rep('OCEAN', 6),
                             rep('L.A.', 54),
                             rep('EUR', 54),
                             rep('AFR', 21),
                             rep('DEV.ASIA ', 18),
                             rep('ASIA', 18)),
             series=rep(c('Out', 'Cons','Inv'), 60))

colnames(vdbeg)[1:3] <- c("WB", "RB", "CB")
colnames(vdend)[1:3] <- c("WE", "RE", "CE")

ggText <-   theme_bw()+theme(axis.text.x = element_text(size = 18)) +
  theme(axis.text.y = element_text(size = 20)) + 
  theme(axis.title = element_text(size = 30)) +
  theme(plot.title = element_text(size=34)) + 
  theme(legend.title = element_text(size=25))+ 
  theme(legend.text = element_text(size=25))

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
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Output") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +ggText
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
  ggText
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
  labs(y="Average Variance Decomposition", x="Region")+
  ggtitle("Variance Decompositions for Investment") +
  ggText
inv 

ggsave(paste("~/GoogleDrive/statespace/", "out_bar.jpeg", sep=""), out,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "cons_bar.jpeg", sep=""), cons,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "inv_bar.jpeg", sep=""), inv,width=12, height=8)

#########################
### Start country VDs ###
#########################

subdata <- bothlong[(bothlong$variable == "CE" & (bothlong$series =="Out")),]
before <-by(subdata[subdata$variable=="CE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "CB" & (bothlong$series =="Out")),]
after <- by(subdata[subdata$variable=="CB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
out <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(),colour="black") +
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Output") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  ggText
out

subdata <- bothlong[(bothlong$variable == "CE") & (bothlong$series =="Cons"),]
before <-by(subdata[subdata$variable=="CE" ,"value"], subdata$regions, mean)
subdata <- bothlong[(bothlong$variable == "CB") & (bothlong$series =="Cons"),]
after <- by(subdata[subdata$variable=="CB","value"], subdata$regions, mean)
compare <- data.frame(ba=factor(cbind(c(1,2))),rbind(before, after))
comparelong <- melt(compare, id.vars = "ba")
cons <- ggplot(data=comparelong) +
  geom_bar(aes(x = variable, y = value, fill=ba),
           stat="identity",position=position_dodge(), colour="black") +
  labs(y="Average Variance Decomposition", x="Region") + 
  ggtitle("Variance Decompositions for Consumption") +
  scale_fill_aaas(name="Period", labels=c("1962-1992", "1992-2014")) +
  ggText
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
  labs(y="Average Variance Decomposition", x="Region")+
  ggtitle("Variance Decompositions for Investment") +
  ggText

ggsave(paste("~/GoogleDrive/statespace/", "out_country_bar.jpeg", sep=""), out, width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "cons_country_bar.jpeg", sep=""), cons,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "inv_country_bar.jpeg", sep=""), inv,width=12, height=8)

#####################

varianceDecomp <- read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/varianceDecomp.csv", col_names=FALSE)
varianceDecomp <- 100*varianceDecomp


worlddf <- data.frame(Name = c("VAR(1)", "World", "Region", "Country"),
              Africa=c(mean(varianceDecomp[AFRICA,1]), mean(varianceDecomp[AFRICA,2]),
              mean(varianceDecomp[AFRICA,3]),mean(varianceDecomp[AFRICA,4])),
              Asia=c(mean(varianceDecomp[ASIA,1]), mean(varianceDecomp[ASIA,2]),
                     mean(varianceDecomp[ASIA,3]),mean(varianceDecomp[ASIA,4])),
              "Dev.Asia"=c(mean(varianceDecomp[ASIADEVELOP,1]), mean(varianceDecomp[ASIADEVELOP,2]),
                               mean(varianceDecomp[ASIADEVELOP,3]),mean(varianceDecomp[ASIADEVELOP,4])),
              Europe=c(mean(varianceDecomp[EUR,1]), mean(varianceDecomp[EUR,2]),
                       mean(varianceDecomp[EUR,3]),mean(varianceDecomp[EUR,4])),
              "L.A."=c(mean(varianceDecomp[LA,1]), mean(varianceDecomp[LA,2]),
                   mean(varianceDecomp[LA,3]),mean(varianceDecomp[LA,4])),
              "N.A."=c(mean(varianceDecomp[NAM,1]), mean(varianceDecomp[NAM,2]),
                  mean(varianceDecomp[NAM,3]),mean(varianceDecomp[NAM,4])),
              Ocean=c(mean(varianceDecomp[OCEAN,1]), mean(varianceDecomp[OCEAN,2]),
                      mean(varianceDecomp[OCEAN,3]),mean(varianceDecomp[OCEAN,4])))
worlddflong <- melt(worlddf)

worlddflong$Name <- relevel(worlddflong$Name, ref="VAR(1)")

world<- ggplot(data=worlddflong) + geom_bar(aes(x = variable, y = value, fill=Name),
           stat="identity",position=position_dodge(), 
           colour="black") + theme_bw()+ labs(y="Average Variance Decomposition", x="Region")+
  scale_fill_aaas() +
  ggtitle("Variance Decompositions Across Regions") +
  ggText
world
ggsave(paste("~/GoogleDrive/statespace/", "full_sample_vd.jpeg", sep=""), world,width=12, height=8)

###################
require(maps)
require(viridis)
library(ggplot2)
library(dplyr)                 
theme_set(
  theme_void()
)






world_map <- map_data("world")
country_names <- read_csv("CodeProjects/R/country_names.csv")
write_csv(country_names, paste("~/GoogleDrive/statespace/", "country_names.csv", sep=""))
wor <- merge(world_map, country_names, by.x="region", by.y="KowCountry", all.x=TRUE)
wor <- wor[order(wor$order),]
wor$val[which(is.na(wor$Val))] <- 0
world_plot <- ggplot(wor, aes(x = long, y = lat, group = group, fill=Val)) +
  geom_polygon(colour = "white", show.legend = FALSE) 
world_plot
ggsave(paste("~/GoogleDrive/statespace/", "countries_in.jpeg", sep=""), world_plot,width=12, height=8)





new_country_names <- read_csv("~/GoogleDrive/statespace/new_country_names.csv", col_names=TRUE)
scaleFill <- scale_fill_gradient(low="#99CFFF", high="#FF0000")
new_country_names$Val <- sumOM$X2
worldLoadingOutput <- new_country_names[new_country_names$Series=='O', ]
worldLoadingOutput$Val <- worldLoadingOutput$Val
worldOutput <- merge(world_map, worldLoadingOutput, by.x="region", by.y="KowCountry", all.x=TRUE)
worldOutput <- worldOutput[order(worldOutput$order),]
worldRegionOutput_plot <- ggplot() + 
  geom_polygon(data=worldOutput,aes(x = long, y = lat, group = group, fill=Val),
               colour = "white", show.legend = FALSE) +
  scaleFill
worldRegionOutput_plot

worldLoadingCons <- new_country_names[new_country_names$Series=='C', ]
worldLoadingCons$Val <-worldLoadingCons$Val
worldCons <- merge(world_map, worldLoadingCons, by.x="region", by.y="KowCountry", all.x=TRUE)
worldCons <- worldCons[order(worldCons$order),]
worldCons <- worldOutput[order(worldCons$order),]
worldRegionCons_plot <- ggplot(worldCons, aes(x = long, y = lat, group = group, fill=Val)) +
  geom_polygon(colour = "white", show.legend = FALSE) +
  scaleFill
worldRegionCons_plot

worldLoadingInv <- new_country_names[new_country_names$Series=='I', ]
worldLoadingInv$Val <-worldLoadingCons$Val
worldInv <- merge(world_map, worldLoadingInv, by.x="region", by.y="KowCountry", all.x=TRUE)
worldInv <- worldCons[order(worldInv$order),]
worldInv <- worldInv[order(worldInv$order),]
worldRegionInv_plot <- ggplot(worldInv, aes(x = long, y = lat, group = group, fill=Val)) +
  geom_polygon(colour = "white", show.legend = FALSE) +
  scaleFill
worldRegionInv_plot

new_country_names <- read_csv("~/GoogleDrive/statespace/new_country_names.csv", col_names=TRUE)
new_country_names$Val <- sumOM$X3
worldLoadingOutput <- new_country_names[new_country_names$Series=='O', ]
worldLoadingOutput$Val <- worldLoadingOutput$Val
worldOutput <- merge(world_map, worldLoadingOutput, by.x="region", by.y="KowCountry", all.x=TRUE)
worldOutput <- worldOutput[order(worldOutput$order),]
worldCountryOutput_plot <- ggplot() + 
  geom_polygon(data=worldOutput,aes(x = long, y = lat, group = group, fill=Val),
               colour = "white", show.legend = FALSE) +
  scaleFill
worldCountryOutput_plot

worldLoadingCons <- new_country_names[new_country_names$Series=='C', ]
worldLoadingCons$Val <-worldLoadingCons$Val
worldCons <- merge(world_map, worldLoadingCons, by.x="region", by.y="KowCountry", all.x=TRUE)
worldCons <- worldCons[order(worldCons$order),]
worldOutput <- worldOutput[order(worldOutput$order),]
worldCountryCons_plot <- ggplot(worldCons, aes(x = long, y = lat, group = group, fill=Val)) +
  geom_polygon(colour = "white", show.legend = FALSE) +
  scaleFill
worldCountryCons_plot

worldLoadingInv <- new_country_names[new_country_names$Series=='I', ]
worldLoadingInv$Val <-worldLoadingCons$Val
worldInv <- merge(world_map, worldLoadingInv, by.x="region", by.y="KowCountry", all.x=TRUE)
worldInv <- worldCons[order(worldInv$order),]
worldInv <- worldInv[order(worldInv$order),]
worldCountryInv_plot <- ggplot(worldInv, aes(x = long, y = lat, group = group, fill=Val)) +
  geom_polygon(colour = "white", show.legend = FALSE) +
  scaleFill
worldCountryInv_plot

ggsave(paste("~/GoogleDrive/statespace/", "worldRegionOutput_plot.jpeg", sep=""), worldRegionOutput_plot,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "worldRegionCons_plot.jpeg", sep=""), worldRegionCons_plot,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "worldRegionInv_plot.jpeg", sep=""), worldRegionInv_plot,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "worldCountryCons_plot.jpeg", sep=""), worldCountryCons_plot,width=12, height=8)
ggsave(paste("~/GoogleDrive/statespace/", "worldCountryInv_plot.jpeg", sep=""), worldCountryInv_plot,width=12, height=8)


