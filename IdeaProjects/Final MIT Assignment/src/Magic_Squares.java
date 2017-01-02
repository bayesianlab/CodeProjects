/**
 * Created by dillonflannery-valadez on 12/25/15.
 */
import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Array;
/*
2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.

        What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?*/

public class Magic_Squares {




    public boolean sumRows(String filename) throws IOException {
        BufferedReader bufferCharacters = getBufferedReader(filename);
        String line = null;
        int counter = 0;
        int truth = getRowSum(bufferCharacters.readLine());
        while( (line = bufferCharacters.readLine()) != null ){
            counter++;
            if( line.split("\t").length == 1) {
                continue;
            }
            else {
                if (truth != getRowSum(line)) {
                    return false;
                }
            }
        }return true;
    }

    public BufferedReader getBufferedReader(String filename) throws FileNotFoundException {
        FileReader convertToCharacter = new FileReader(filename);
        return new BufferedReader(convertToCharacter);
    }

    private int getRowSum(String line) {
        String regEx = "\t";
        int rowSum =0;
        for(String elem : line.split(regEx)){
            rowSum += Integer.valueOf(elem);
        }
        return rowSum;
    }

    public boolean sumColumns(String filename) throws IOException{
        BufferedReader text = getBufferedReader(filename);
        String line = null;
        int[] colSum = new int[9];
        while( (line = text.readLine()) != null){
            String[] split = (line.split("\t"));
            int cols = split.length;
            if( split.length == 1) {
                continue;
            }
            else{
                for(int i=0; i < cols; i++){
                    colSum[i] += Integer.valueOf(split[i]);
                }
            }
        }
        return checkArrayEqual(colSum);
    }

    public boolean checkArrayEqual(int[] integerArray){
        int truth = integerArray[0];
        for (int number : integerArray) {
            if(truth != number){
                return false;
            }
        }
        return true;
    }

    public int checkDiagonal(String filename) throws IOException{
        BufferedReader text = getBufferedReader(filename);
        int[] diag = new int[9];
        String line = null;
        int diagonalIndex = 0;
        while( (line = text.readLine()) != null){
            String[] split = line.split("\t");
            for(int column = 0; column < split.length; column++){
                if(column == diagonalIndex){
                    diag[column] = Integer.valueOf(split[column]);
//                    System.out.print(" " + split[column]);
                    diagonalIndex++;
                    break;
                }
            }
        }  return sumArray(diag);
    }

    public int sumArray(int[] someArray){
        int sum = 0;
        for (int number:someArray) {
            sum += number;
        } return sum;
    }

    public int checkReverseDiagonal(String filename) throws IOException {
        BufferedReader text = getBufferedReader(filename);
        int[] diag = new int[9];
        String line = null;
        int diagonalIndex = 8;
        while ((line = text.readLine()) != null) {
            String[] split = line.split("\t");
            if(split.length > 1){
                for (int column = 0; column < split.length; column++) {
                    if (column == diagonalIndex) {
                        diag[column] = Integer.valueOf(split[column]);
                        diagonalIndex--;
                        break;
                    }
                }
            }
        } return sumArray(diag);
    }

    public String declareMagicSquare(String filename) throws IOException{
        if(checkReverseDiagonal(filename) == checkDiagonal(filename) &&
                sumRows(filename) == sumColumns(filename)){
            return "FOUND MAGIC SQUARE.";
        }else{ return "NOT MAGIC SQUARE.";}
    }
}
