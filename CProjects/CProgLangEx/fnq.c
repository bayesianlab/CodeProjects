#include <stdio.h>
#include <string.h>

#define MaxSize 1000

void histogram();

void placeWord();

int sumArray();

void initZeroArray(); 

char *readWord();

int *numBins();

int isDivisible();

int *fillBins();

int minLengthWord();

int maxLengthWord();


int main()
{
	char c[MaxSize];
	int bins[5];
	int w;
	int strLen;
	int *binPointer;
	int *hist;
	int wordCountArray[4];
	printf("user input\n");
	fgets(c, sizeof(c), stdin);
	hist = fillBins(c, wordCountArray, 5, MaxSize);
	histogram(hist, 5);
	return 1;
}

void histogram(int wordCountArray[], int arrayLen){
	printf("..................... Histogram .....................\n");
	int i;
	int j;
	for(i = 0; i < arrayLen; ++i){
		printf("%d  words in bin %d:\n\t\t\t", wordCountArray[i], i+1);
		for(j = 0; j < wordCountArray[i]; ++j){
			printf("#");
		}
	   printf("\n");	
	} 
} 

int *fillBins(char *inputWord,int wordCountArray[], int nBins,  int maxSize)
{

	int bins[nBins-1];
	int *binPointer;
	int minWord;
	int maxWord;
	minWord = minLengthWord(inputWord, maxSize);
	maxWord = maxLengthWord(inputWord, maxSize);
	binPointer = numBins(minWord, maxWord, bins, nBins);
    int c, count, wl;
	int i;
	int letter;
	int totalWordCount =0;
	initZeroArray(wordCountArray, nBins-1);
	letter = 0;
	wl=0;
	while(letter < maxSize){
		c = inputWord[letter];
		if(c == '\0'){
			++totalWordCount;
			--wl;
			placeWord(wordCountArray, binPointer, wl, 5);
			break;
		}
	   if(c == ' ' && wl > 0){
		   ++totalWordCount;
		  placeWord(wordCountArray, binPointer, wl, 5); 
		   wl=-1;
	   } 
	    ++letter;
		++wl;
	}
	printf("\n\t Summary: \n");
	if(nBins >= totalWordCount){
		printf("\n \tYou specified %d bins for a total of %d words (including extra whitespace)\n"
				"\tThis may not be a good idea, consider using fewer bins\n", nBins, totalWordCount);
	}
   else{
		printf("\n \tYou specified %d bins for a total of %d words (including extra whitespace)\n", 
				nBins, totalWordCount);
   } 	   
	for(i=0;i<nBins;++i){
		printf("\t\tCount in bin %d = %d \n", i+1, wordCountArray[i]);
	}
	printf("\t\tCheck sum........%d\n\n\n", sumArray(wordCountArray, 5));	 
	return wordCountArray;
} 

int minLengthWord(char *inputWord, int maxSize)
{
	printf("\n\tFinding minimum word in string..."); 
	char foundWordMessage[] = "\n\tSmallest Word has length: ";  

    int  c, wl, min, iteration;
    wl = 0;
	c = 0;
	iteration = 0;
	while(c < maxSize)
	{
		if(inputWord[c] == ' ')
		{
			++iteration;
			if(iteration == 1)
			{
			min = wl;
			} 
			else if(wl < min && wl > 0)
			{
				min = wl;
			} 
			wl = -1;
		} 
		else if(inputWord[c] == '\n')
		{
			if(wl < min && wl > 0)
			{
				printf("%s %d\n", foundWordMessage, wl); 	
				return wl;
			} 
			else
			{
				printf("%s %d\n", foundWordMessage, min); 	
				return min; 
			} 
		} 
			++c;
			++wl;
	} 
	printf("Error, didnt find min\n"); 
	return -1;
} 

int maxLengthWord(char *inputWord, int maxSize)
{
	printf("\n\tFinding maximum word in string..."); 
	char foundWordMessage[] = "\n\tLargest word has length: ";  
    int  c, wl, max, iteration;
    wl = 0;
	c = 0;
	iteration = 0;
	max = 0;
	while(c < maxSize)
	{
		if(inputWord[c] == ' ')
		{
			++iteration;
			if(iteration == 1){
				max = wl;
			} 
			else if(wl > max && wl > 0){
				max = wl;
			} 
			wl = -1;
		} 
		else if(inputWord[c] == '\n')
		{
			if(wl > max && wl > 0)
			{
				printf("%s %d\n", foundWordMessage, wl); 	
				return wl;
			} 
			else
			{
				printf("%s %d\n", foundWordMessage, max); 	
				return max; 
			} 
		} 
			++c;
			++wl;
	} 
	printf("Error, didnt find max, c= %d\n", c); 
	return -1;
}  

int isDivisible(int divisand, int divisor)
{
	int res;
	res = divisand/divisor;
	if( res * divisor == divisand){
		return 1;
	} 
	else{
		return 0;
	} 
} 

int *numBins(int min, int max, int bins[], int nBins)
{
	if(min > max){
		printf("Minimum greater than max! Error.\n"); 
		return 0;
	} 
	printf("\n\tCalculating bins intervals...  "); 
	int spread, interval, i;
	spread = max - min;
	interval = spread / nBins;
	if(nBins > spread){
		printf("\nError in numBins: Not a long enough input string "
				"for specified number of bins.\n Defaulting to one, bin=maxSize.\n");
		initZeroArray(bins, nBins);
		bins[0] = max;
		return bins;
	}
	if(isDivisible(spread, nBins) == 1){
		for(i = 0; i < nBins ; ++i){
			min = min + interval;
			bins[i] = min;	
		} 
	}
	else{
		for(i = 0; i < (nBins - 1); ++i){
				min = min + interval;
				bins[i] = min;	
			}
		bins[i] = max;
	}
	printf("The bin intervals have been\n \tcalculated as follows: "); 	
	for(i=0; i < nBins; i ++){
		if(i == nBins - 1){
			printf("%d.", bins[i]); 
		}
	   else{
			printf("%d, ", bins[i]);
	   } 	   
	} 
	printf("\n"); 
	return bins;
}


char *readWord(char *userInput, char charArray[], int maxSize){
	printf("\n\tConvert string to array...\n");
	int letter;
	for(letter=0; letter < maxSize; letter++){
		charArray[letter] = userInput[letter];
		if(userInput[letter] == '\0'){
			return userInput;
		} 
	} 
	return "c";
}

void initZeroArray(int someArray[], int size){
	int i = size;
	for(i=0; i < size; i++){
		someArray[i] = 0;
	}	
} 

int sumArray(int someArray[], int length){
	int arraySum =0;
	for(int i=0; i < length; ++i){
		arraySum = arraySum + someArray[i];
	} 
	return arraySum;
}

void placeWord(int wordCountBreaks[], int binIntervals[], int wordLen, int breaks){
	int j;
	for(j=0; j < breaks; ++j){
		if(wordLen <= binIntervals[j] && wordLen > 0){
wordCountBreaks[j] = wordCountBreaks[j] + 1;
			break;
		} 
	} 
} 
