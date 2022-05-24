library(readr)
collins_dictionary <- data.frame(read_table2("CodeProjects/CProjects/hackerrank/collins_dictionary.txt",col_names = FALSE))
collins_dictionary <-na.omit(collins_dictionary)
j <- 1
for(i in collins_dictionary$X1)
{
  if(nchar(i) <= 2)
  {
    collins_dictionary$X1[j] <- NA 
  }
  j <- j + 1
}

collins_dictionary <- na.omit(collins_dictionary)

write.table(collins_dictionary, "CodeProjects/CProjects/hackerrank/collins_dictionary.txt", col.names = FALSE, row.names = FALSE, quote=FALSE)

