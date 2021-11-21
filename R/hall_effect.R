# Hall effect
library(readr)
library(ggplot2)
hall_effect <- read_csv("GoogleDrive/Datasets/hall_effect.csv")
hall_effect <- cbind(hall_effect, hall_effect$x*hall_effect$x, hall_effect$x*hall_effect$x*hall_effect$x)

colnames(hall_effect)[3] <- "x2"
colnames(hall_effect)[4] <- "x3"
mod1 <- lm(y~ x , data=hall_effect)
mod2 <- lm(y~x + x2 , data=hall_effect)
mod3 <- lm(y~x + x2 + x3, data=hall_effect)
summary(mod1)
summary(mod2)
summary(mod3)
hall_effect <-  cbind(hall_effect, mod1$fitted.values, mod2$fitted.values, mod3$fitted.values)
colnames(hall_effect)[5] <- "mod1"
colnames(hall_effect)[6] <- "mod2"
colnames(hall_effect)[7] <- "mod3"
p1<- ggplot(data=hall_effect, aes(x=x,y=y)) + geom_point() + 
  geom_point(aes(x=x,y=mod1), colour="red") 
p1
p2<- ggplot(data=hall_effect, aes(x=x,y=y)) + geom_point() + 
  geom_point(aes(x=x,y=mod2), colour="orange") 
p2
p3<- ggplot(data=hall_effect, aes(x=x,y=y)) + geom_point() + 
  geom_point(aes(x=x,y=mod3), colour="magenta") 
p3
