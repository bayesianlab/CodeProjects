clear 
reset
set boxwidth .1
n = 1000
bin(x,w) = w* (floor(x/w) + .5)
set xrange [-2.5:20]
set multiplot layout 2,1
plot 'shiftedexp.txt' using (bin($1,.1)):(1.0/(.1*n))  smooth frequency with boxes
plot 'shiftedexp.txt' using 2:3 with lines lc rgb "red"
