library(readr)
library(BCDating)


worldgdp <- read_csv("gdrivelocal/Datasets/Probitdata/GlobalData/worldgdp.csv")
names <- colnames(worldgdp)
recessions <- matrix(nrow=dim(worldgdp)[1], ncol=dim(worldgdp)[2])
for(i in 1:dim(worldgdp)[2]){
  # i <-7
  tsgdp <- ts(worldgdp[,i], frequency = 4, start=c(2004,2))
  # plot(tsgdp)
  bq <- BBQ(tsgdp, name='GDP', mincycle=4)  
  s <- show(bq)
  y <- matrix(nrow=20, ncol=4)
  y <- as.data.frame(y)
  rownames(y) <- seq(2004,2023)
  colnames(y) <- c('Q1', 'Q2', 'Q3', 'Q4')
  q <- seq(2004.00, 2023.00, by=.25)
  df <- as.data.frame(matrix(nrow=length(q), ncol=2))
  df[,1] <- q
  for(j in 1:dim(s)[1]){
    # j <- 3
    if(is.na(s[j,1])){
      u <- 2004
      x <- 'Q1'
    }else{
      u <- as.numeric(substring(s[j, 1], 1, 4))
      x <- substring(s[j, 1], 5)  
    }
    
    if(x=='Q1'){
      pm <- 0 
    }else if (x=='Q2'){
      pm <- .25
    }else if(x=='Q3'){
      pm <- .5 
    }else{
      pm <- .75
    }
    u <- u + pm
    v <- 1
    if(is.na(s[j,3])){
      end_cond <- dim(df)[1] - which(df$V1==u, arr.ind = TRUE) 
    } else{
      end_cond <- s[j,3]
    }
    while(v <= end_cond){
      u <- u + .25
      df[df$V1==u,2] <- 1
      v <- v + 1
    }
  }
  
  recessions[,i] <- df$V2
  
}
recessions <- as.data.frame(recessions)
colnames(recessions) <- names 








df
s
