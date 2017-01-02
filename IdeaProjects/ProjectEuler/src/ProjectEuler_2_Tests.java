/**
 * Created by dillonflannery-valadez on 12/16/15.
 */

public class ProjectEuler_2_Tests {
    double epsilon = .0001;
    private String testPassString = "Test passed";
    private String testFailedString = "Test failed";

    public String verifyEquals(int x, int y) {
        this.testPassString = "Test passed";
        this.testFailedString = "Test failed.";
        if(x != y){
            return testFailedString;
        } else return testPassString;
    }

    public void verifyAlmostEquals(double x, double y){
        if( Math.abs( x - y) < epsilon){
            System.out.println(testPassString + " " +  x + " " +  y );
        }
        else System.out.println(testFailedString + " " +  x  + " " + y );
    }

    public static void main(String[] args) {
        ProjectEuler_2_Tests verify = new ProjectEuler_2_Tests();
        ProjectEuler_2 trial = new ProjectEuler_2();
//        verify.verifyAlmostEquals(trial.golden, 1.618);
//        verify.verifyAlmostEquals(trial.invGolden, -0.618);
//        verify.verifyAlmostEquals(3.0, trial.computeNthFib(4));
        System.out.println(trial.findBiggestFib(4000000));
        trial.getEvenFibs(33);
        System.out.println(trial.sumArrayList(trial.fibList));
        System.out.println(trial.fibList);
    }

}
