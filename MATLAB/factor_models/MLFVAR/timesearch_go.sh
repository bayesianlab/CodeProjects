#$ -q its
#$ -N timesearch_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./TimeBreakSearch 5000 1000 4000 totaltime.mat
