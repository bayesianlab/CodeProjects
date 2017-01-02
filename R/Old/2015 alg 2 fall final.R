stu <- c("jun", "deb", "mar", "eripr", "gust", "eriliu", "gab", "kar", "pris")
score <- c(24.5, 24, 19.5, 21.5, 23.5, 9, 17, 16.5, 21.5) 
stu_v_score <- cbind(stu, score) 
summary(score)

boxplot(as.numeric(stu_v_score[,2]))
hist(score, breaks = 7)