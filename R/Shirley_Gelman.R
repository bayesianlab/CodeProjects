# Shirley and Gelman paper
library(foreign)
library(readr)
x <- read.spss("/Users/dillonflannery-valadez/Desktop/g200618.por", to.data.frame = TRUE)
read_fwf("/Users/dillonflannery-valadez/Desktop/feb8_2009.dat", 
         fwf_positions(13,15, col_names = "weights")


