library(ggplot2)
djia <- rnorm(1000, 0.001, .0098)
djia

xbars <- apply(replicate(625, sample(djia, 20)), 2, mean)
xbars <- as.data.frame(xbars)

ggplot(xbars, aes(xbars)) + geom_histogram(binwidth = .0004, colour="blue", 
                                           fill="black") +
  labs(x = "625 sample averages based on sample of size 20",
       title = "DJIA~N(0.0010, 0.0098)")
  

