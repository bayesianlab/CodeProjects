clear 
reset
set boxwidth .1
set multiplot layout 2,3
n = 1000
bin(x,w) = w* (floor(x/w) + .5)
plot 'testfile.txt' using (bin($1,.1)):(1.0/(.1*n))  smooth frequency with boxes
plot 'testfile.txt' using (bin($2,.1)):(1.0/(.1*n))  smooth frequency with boxes
plot 'testfile.txt' using (bin($3,.1)):(1.0/(.1*n))  smooth frequency with boxes

set xrange [0:20]
plot 'igamma.txt' using (bin($1,.1)):(1.0/(.1*n)) smooth frequency with boxes



