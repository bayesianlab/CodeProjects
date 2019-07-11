load("/Users/dillonflannery-valadez/Downloads/star.rda")
library(plm)
starpanel <- pdata.frame(star, c("schid"))
f<-plm(mathscore~small+aide+tchexper+boy+white_asian, index=c("schid"), model=c("within"), data=starpanel)
summary(f)
fixef(f)
fp<-plm(mathscore~small+aide+tchexper+boy+white_asian, index=c("schid"), model=c("pooling"), data=starpanel)
summary(fp)

lm(mathscore~small+aide+tchexper+boy+white_asian, data=star)

load("/Users/dillonflannery-valadez/Downloads/liquor.rda")
l1 <- as.matrix(liquor$l2 - liquor$l1)
l2 <- as.matrix(liquor$l3 - liquor$l2)
x1 <- as.matrix(liquor$x2 - liquor$x1)
x2 <- as.matrix(liquor$x3 - liquor$x2)
yfd<- rbind(l1,l2)
xfd<- rbind(x1,x2)

summary(lm(yfd~xfd-1))

fxy <- (liquor$l1 + liquor$l2 + liquor$l3)/3
fxx <- (liquor$x1 + liquor$x2 + liquor$x3)/3

fxy1 <- as.matrix(liquor$l1 - fxy)
fxy2 <- as.matrix(liquor$l2 - fxy )
fxy3 <- as.matrix(liquor$l3 - fxy)
fxx1 <- as.matrix(liquor$x1 - fxx)
fxx2 <- as.matrix(liquor$x2 - fxx)
fxx3 <- as.matrix(liquor$x3 - fxx)
yfx<-rbind(fxy1,fxy2,fxy3)
xfx<-rbind(fxx1,fxx2, fxx3)
summary(lm(y~x-1))
