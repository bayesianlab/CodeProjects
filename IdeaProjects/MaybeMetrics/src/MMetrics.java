import Jama.CholeskyDecomposition;
import org.apache.commons.math3.distribution.MultivariateNormalDistribution;
import org.apache.commons.math3.distribution.NormalDistribution;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.*;
import java.io.FileInputStream;

/**
 * Created by dillonflannery-valadez on 4/12/16.
 */


public class MMetrics {

    public void X(){
        NormalDistribution x = new NormalDistribution(0, 1);
        System.out.println(x.cumulativeProbability(0));
    }
    public static void main(String[] args) {
        MMetrics m =new  MMetrics();
        try {
            FileInputStream file = new FileInputStream( new File("/Users/dillonflannery-valadez/Google Drive/" +
                    "MATLAB/Econometrics/Homework2_Q3/Data_PS2a_S15-2.xlsx"));
            HSSFWorkbook wb = new HSSFWorkbook(file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }catch (IOException e){
            e.printStackTrace();
        }
    }
}
