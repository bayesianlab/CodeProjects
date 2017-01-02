#survey grades
score <- c(.444, .429, .778, .905, .492, .175, .683, .429)
person <- c("andrea", "april", "rebekah", "amanda",
            "isaac", "andrew", "elissa", "brody" )

as = c()
bs = c()
cs = c()
ds = c()
ja = 0
jb = 0
jc = 0
jd = 0
mat <- cbind(score, person)
for (i in (1:length(person))) {
  if(score[i] >= .7068){
    ja = ja + 1
    as[ja] = person[i]
  }
  if( score[i] < .7068 & .468 <= score[i]){
    jb = jb + 1
    bs[jb] = person[i]
  }
  if( score[i] <.468 & .4290 <=score[i]){
    jc = jc + 1
    cs[jc] = person[i]
  } 
  if(score[i] < .429){
    jd  = jd + 1
    ds[jd] = person[i] 
  }

}

print(as)
print(bs)
print(cs)
print(ds)
summary(score)
hist(score)
boxplot(score)