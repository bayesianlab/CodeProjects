import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.FileReader;


/**
 * Created by dillonflannery-valadez on 12/16/15.
 */
public class ProjectEuler_3 extends ConstructPrimeList {
    ArrayList primeFactorList = new ArrayList();

    public long multiplyArray(ArrayList primes){
        long product =1;
        if (primes.size() == 0){
            return 0;
        }
            for(int i=0; i < primes.size(); i ++){
                String num =  String.valueOf(primes.get(i));
                long x = Long.valueOf(num);
                product = product * x;
            }
            return product;
    }

    public ArrayList repeatedPrimeFactors(long number, int currentTestPrime){
        ArrayList tempStore = new ArrayList();
        while((number % currentTestPrime) == 0) {
            if (currentTestPrime == 1) {
                tempStore.add(currentTestPrime);
                return tempStore;
            }
            tempStore.add(currentTestPrime);
            number = number / currentTestPrime;
        } return tempStore;
    }

    public void primate2(Long num){
        for(int i = primeNumberList.size() - 1; i >= 0; i --){
            int currentTestPrime = (int) primeNumberList.get(i);
            primeFactorList.addAll(repeatedPrimeFactors(num, currentTestPrime));
        }
    }


    public long hackToSize(long number){
        for(int i = 0; i < primeFactorList.size(); i ++){
            number = number / (int) primeFactorList.get(i);
        } return number;
    }
}
