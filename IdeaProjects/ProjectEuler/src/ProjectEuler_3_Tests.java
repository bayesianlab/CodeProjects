import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by dillonflannery-valadez on 12/16/15.
 */
public class ProjectEuler_3_Tests {

    public void print(Object arg){
        System.out.println(arg);
    }


    public void test_primate(){
        ProjectEuler_3 x = new ProjectEuler_3();
        x.primeNumberList.clear();
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-100k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-200k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-300k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-400k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-500k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-600k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-700k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-800k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-900k.txt");
        x.constructAnotherList("/Users/dillonflannery-valadez/IdeaProjects/primes-to-1000k.txt");
        long a = 1L;
        long b = 6L;
        long c = 243L;
        long d = 123321L;
        long e = 600851475143L;
//        x.primate2(a);
//        System.out.println(x.primeFactorList);
//        x.primeFactorList.clear();
//        x.primate2(b);
//        System.out.println(x.primeFactorList);
        x.primeFactorList.clear();
        x.primate2(c);
        System.out.println(x.primeFactorList);
        System.out.println(x.multiplyArray(x.primeFactorList));
//        x.primeFactorList.clear();
//        x.primate2(e);
//        System.out.println(x.hackToSize(e));
//        System.out.println(x.multiplyArray(x.primeFactorList));
    }

    public static void main(String[] args){
        ProjectEuler_3_Tests test =  new ProjectEuler_3_Tests();
        test.test_primate();
    }
}
