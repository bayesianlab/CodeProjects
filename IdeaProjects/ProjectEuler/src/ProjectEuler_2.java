import java.util.ArrayList;

/**
 * Created by dillonflannery-valadez on 12/16/15.
 */
public class ProjectEuler_2 {
    private double root5 = Math.pow(5.0, 1 / 2.0);
    double golden = (1 + root5)/2;
    double invGolden = (1 - root5)/2;
    ArrayList fibList;


    public double computeNthFib(int n){
        double num = Math.pow(golden, n) - Math.pow(invGolden, n);
        return num/ root5;
    }

    public void getEvenFibs(int nthFib){
        int n = 0;
        ArrayList fibs = new ArrayList();
        for(int i = 1; n < nthFib; i ++){
            n = i * 3;
            fibs.add(computeNthFib(n));
        }
        fibList = fibs;
    }

    public double sumArrayList(ArrayList listOfNums){
        double sum = 0;
        for(int i = 0 ; i < listOfNums.size(); i ++){
            double x = (double) listOfNums.get(i);
            sum += x;
        }
        return sum ;
    }

    public double findBiggestFib(double maxVal){
        int n;
        int i = 1;
        while (true){
            i += 1;
            n = i*3;
            if(computeNthFib(n) > maxVal){
                return n - 3;
            }
        }
    }
}
