//
//  xcf.c
//  xcodeC
//
//  Created by Dillon Flannery-Valadez on 1/5/17.
//  Copyright © 2017 Dillon Flannery-Valadez. All rights reserved.
//

#include "xcf.h"
#include <stdio.h>
#include <stdlib.h>

void cutString(char s[], char sub[], int start, int end);

void cs2(char s[], char* is[], int start, int end);

int dataInRow(int rowIndices[], int lenArray, int row);

int main(int argc, char *argv[])
{
    FILE *fp;
    int i =-1;
    size_t c = 0;
    char *x = NULL;
    ssize_t read;
    
    char *endptr;
    long numRecords;
    numRecords = 2;
    int rowIndices = {1};
    int lenIndices = 1;
    
    
    
    fp = fopen("/Users/dillonflannery-valadez/Desktop/test.txt", "r");
    if(fp == NULL)
    {
        printf("Error reading file\n");
        exit(0);
    }
    while((read = getline(&x, &c, fp)) != -1)
    {
        i++;
        if(dataInRow(&rowIndices, lenIndices, i) == 1)
        {
            char sub[4];
            cutString(x, sub, 4, 8);
            printf("%s\n", sub);
            
        }
        if(i == numRecords-1)
        {
            i=-1;
        }

    }

}

void cutString(char s[], char sub[], int start, int end)
{
    int i;
    int j = 0;
    for(i = start; i < end; i++)
    {
        if(s[i] == '\0')
        {
            break;
        }
        else
        {
            sub[j] = s[i];
            j++;
            
        }
    }
}

int dataInRow(int rowIndices[], int lenArray, int row)
{
    for(int i = 0; i < lenArray; i ++)
    {
        if(row == rowIndices[i])
        {
            return 1;
        }
    }
    return 0;
}



