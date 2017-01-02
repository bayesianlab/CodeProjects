import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by dillonflannery-valadez on 12/14/15.
 */


public class ProjectEuler_1_Tests {
    ProjectEuler_1 testInstance = new ProjectEuler_1();
    int[] multiples= {3,5,6,9};
    ArrayList multsOf3 = new ArrayList(
            Arrays.asList(3,6,9)
    );
    private String testPassString = "Test passed";
    private String testFailedString = "Test failed";

    public String verifyEquals(int x, int y) {
        this.testPassString = "Test passed";
        this.testFailedString = "Test failed.";
        if(x != y){
            return testFailedString;
        } else return testPassString;
    }

    public String verifyArrayListEqual(ArrayList x, ArrayList y){
        for( int i= 0; i < x.size(); i ++){

            if(x.get(i) != y.get(i)){
                return testFailedString + " lists not equal " + x.get(i) + " " + y.get(i);
            }
        }return testPassString;
    }


    public void multiples_Test() {
        testInstance.multiplesOf3();
        testInstance.multiplesOf5();
        System.out.println(testInstance.sumArrayList(testInstance.multiples));
    }

    public static  void main(String[] args){
        ProjectEuler_1_Tests runTests;
        runTests = new ProjectEuler_1_Tests();
        runTests.multiples_Test();
        System.out.println();
    }

}
