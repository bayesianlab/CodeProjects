# Quiz 1 Finance
source('~/R projects/annuity.R', echo=TRUE)
source('~/R projects/pvalfunc.R', echo = T)

# Q1
annuity('x', 4300, 9, 15)

# Q1 a  
annuity('x', 4300, 9, 60)

# Q1 b
4300/.09

# Q2 
pval(annuity('x', 5000, 8, 23), 8, 2)

# Q3
pval(15000, 9/4, 40)

# Q4
fval(10100, 5, 6)

# Variations

4300/.1881
pval(annuity('x', 5000, 8, 23), 10, 2)
