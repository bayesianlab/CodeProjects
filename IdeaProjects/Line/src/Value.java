import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.ChartFactory;
import org.jfree.data.general.DefaultPieDataset;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.DoubleSummaryStatistics;
import java.util.LinkedHashMap;
import java.lang.Math;

/**
 * Created by dillonflannery-valadez on 3/6/16.
 */
public class Value {
    public LinkedHashMap value_function = new LinkedHashMap();
    public double statestart = 0.0;
    public double stateend = 1.0;
    public double stepsize = 0.001;
    public ArrayList state_space = linspace(statestart, stateend, stepsize);
    private int state_space_length;
    XYSeries vfunciterations = new XYSeries("Value Funciton");


    public Value(){
        int state_space_length =  state_space.size();
        for(int i  =0; i < state_space_length; i++) {
            value_function.put(i, 0.0);
        }
    }

    public ArrayList linspace(double begin,double end, double step){
        ArrayList space = new ArrayList();
        double steps = (end - begin)/step;
        double grid = 0;
        for(int i=0; i < steps + 1; i ++){
            space.add(grid);
            grid += step;
        }
        return space;
    }

    public double value(int state_index, int stateprime_index){
        double A = 4.0;
        double a = 1.0;
        double beta = 0.90;
        int A2 = 4;
        double sprime = (Double)state_space.get(stateprime_index);
//        double sprime_wait = (Double)state_space.get(A2*state_index);
        double state = (Double) state_space.get(state_index);
        double firstpart = (A*state - sprime);
        double secondpart = java.lang.Math.pow((A*state - sprime), 2);
        if(A*state < sprime){
            return -999999*-999999;
        }else{
            double value = (Double)value_function.get(stateprime_index);
//            System.out.println(value + " value");
            double cons =  firstpart - (a/2.0)*secondpart + beta*value ;
            return cons;
        }
    }

    public void search_statespace(){
        int state_space_length =  state_space.size();
        for(int state = 0; state < state_space_length; state ++){
            ArrayList temporary = new ArrayList();
            for(int state_prime = 0; state_prime < state_space_length; state_prime ++){
                temporary.add(value(state, state_prime));
            }
            value_function.put(state, Collections.max(temporary));
        }
    }

    public void contraction_map(int iters){
        int contractions = 0;
        while(contractions< iters){
            contractions++;
            search_statespace();
        }
    }

    public void xy_pairs(int iters){
        contraction_map(iters);
        for(int i = 0; i < state_space.size(); i++){
            double pi = (Double)value_function.get(i);
            double si = (Double)state_space.get(i);
            vfunciterations.add(si, pi);
        }
    }

}
