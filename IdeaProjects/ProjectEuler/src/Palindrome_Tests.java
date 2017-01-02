import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by dillonflannery-valadez on 12/22/15.
 */
public class Palindrome_Tests {
    public static void main(String[] args){
        ProjectEuler_3 factors = new ProjectEuler_3();
        Palindrome_3_Digit tester = new Palindrome_3_Digit();

//        isPalindromeTest(tester);
        tester.findPossibilities(tester.maxPossible, tester.lowPossible);
        System.out.println(tester.possibilities.size() + " size of possibilities");
        constructPrimeList(factors);
        test_multArray(tester);
        test_multiplyTogether(tester);


        for(int i = 0; i < tester.possibilities.size() - 100; i ++){
            factors.primeFactorList.clear();
            factors.primate2(  tester.castIntToLong((int) tester.possibilities.get(i)));
            if(factors.primeFactorList.size() > 1 &&
                    (int)factors.primeFactorList.get(0) < 1000 &&
                    (int) factors.primeFactorList.get(1) < 100 ){
                System.out.println(factors.primeFactorList + " " + tester.multiplyTogether(factors.primeFactorList)
                        + " " + String.valueOf(tester.possibilities.get(i)) );
                System.out.println();
            }
        }

    }

    public static void test_multArray(Palindrome_3_Digit tester){
        ArrayList testList = new ArrayList(Arrays.asList(3));
        System.out.println(tester.multArray(testList));

    }

    public static void test_multiplyTogether(Palindrome_3_Digit tester){
        ArrayList testList = new ArrayList(Arrays.asList(359, 11, 11, 7, 3, 1));
        System.out.println(tester.multiplyTogether(testList));
    }

    public static void constructPrimeList(ProjectEuler_3 factors) {
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-100k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-300k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-400k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-500k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-600k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-800k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-900k.txt");
        factors.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-1000k.txt");
    }

    public static void isPalindromeTest(Palindrome_3_Digit tester) {
        System.out.println(tester.isPalindrome(String.valueOf(8886)) + " Should be false, 8886");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(2)) + " Should be true, 2");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(1000000000)) + " Should be false, 10000000...");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(101)) + " Should be true, 101");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(990979)) + " Should be false, 990979");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(990099)) + " Should be true, 990099");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(19900991)) + " Should be true, 19900991");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(997999)) + " Should be false, 997999");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(997799)) + " Should be true, 997799");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(860768)) + " Should be false, 860768");
        System.out.println();
        System.out.println(tester.isPalindrome(String.valueOf(870478)) + " Should be false, 870478");
        System.out.println();
    }
}
