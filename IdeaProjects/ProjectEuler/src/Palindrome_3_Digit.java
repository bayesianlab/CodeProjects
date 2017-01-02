import java.util.ArrayList;

/**
 * Created by dillonflannery-valadez on 12/22/15.
 */
public class Palindrome_3_Digit {

    int maxPossible = 998001;
    int lowPossible = 490000;
    ArrayList possibilities = new ArrayList();


    public void findPossibilities(int max, int min){
        for(int i = max; i > min; i --){
            if(isPalindrome(String.valueOf(i))) {
                possibilities.add(i);
            }
        }
    }

    public boolean isPalindrome(String textNumb){
        int endIndex = textNumb.length() - 1;
        if( textNumb.length() <= 1){
            return true;
        }
        else{
            if(textNumb.charAt(0) == (textNumb.charAt(endIndex) )){
                textNumb = textNumb.substring(1, endIndex);
                return isPalindrome(textNumb);
            }
            else{
                return false;
            }
        }
    }
    public long castIntToLong(int someInteger){
        String num =  String.valueOf(someInteger);
        long x = Long.valueOf(num);
        return x;
    }

    public int findMin(ArrayList aList){
        int min = 0;
        int indxOfMin = 0;
        min = (int) aList.get(0);
        for(int i =0 ; i <aList.size(); i ++){
            if(min > (int) aList.get(i)){
                min = (int) aList.get(i);
                indxOfMin = i;
            }
        } return  indxOfMin;
    }

    public int findMax(ArrayList aList){
        int max = 0;
        int indxOfMin = 0;
        max = (int) aList.get(0);
        for(int i =0 ; i <aList.size(); i ++){
            if(max < (int) aList.get(i)){
                max = (int) aList.get(i);
                indxOfMin = i;
            }
        } return  indxOfMin;
    }

    public int multArray( ArrayList someList){
        int product = 1 ;
        for(int i =0; i < someList.size() ; i ++ ){
            product = product * (int) someList.get(i);
        } return product;
    }

    public ArrayList multiplyTogether(ArrayList factorList) {
        if (factorList.size() > 2) {
            ArrayList threeDigitList = new ArrayList();
            int thresh = (int) factorList.get(findMax(factorList));
            factorList.remove(findMax(factorList));
            while(true){
                int min = findMin(factorList);
                if( (int) factorList.get(min) * thresh < 1000){
                    thresh = (int) factorList.get(min) * thresh;
                    factorList.remove(min);
                    if(factorList.size() <= 2){
                        break;
                    }
                }else break;
            }
            threeDigitList.add(thresh);
            int remainder = 0;
            remainder = multArray(factorList);
            threeDigitList.add(remainder);
            return threeDigitList;
        } else return factorList;
    }
}
