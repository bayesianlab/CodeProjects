family <- data.frame(fmli161x)

newdf <- data.frame(matrix(0, nrow = 2, ncol = 2))

# 10th percentile
newdf[1,] <- colMeans(family[family$INC_RANK < .1, c("ETOTALP", "EHOUSNGP")])
# Between 10th and 20th percentile
newdf[2,] <- colMeans(family[family$INC_RANK >= .1 & family$INC_RANK < .2, c("ETOTALP", "EHOUSNGP")])

write_csv(newdf, "newdf.csv")

