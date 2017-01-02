/**
 * Created by dillonflannery-valadez on 3/6/16.
 */

import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.ChartFactory;
import org.jfree.data.general.DefaultPieDataset;
import java.io.File;

public class VFunc {
    public static void main(String[] args) {
        final long start = System.currentTimeMillis();
        Value testValue1 = new Value();
        Value testValue2 = new Value();
        Value testValue3 = new Value();
//        System.out.println(testValue1.linspace(0.0, 1.0, .10) + "Linspace test");
////        testValue.search_statespace();
//        System.out.println(testValue1.state_space + " initialize statespace");
//        testValue1.search_statespace();
////        System.out.println(testValue.value_function);
//        System.out.println(testValue1.value(10, 5) + " value test");
//        System.out.println(testValue1.value_function.size() + " value function size");
//        testValue1.contraction_map(5);
//        System.out.println(testValue1.value_function + " contraction map");
        testValue1.xy_pairs(10);
        testValue2.xy_pairs(20);
        testValue3.xy_pairs(40);

        XYSeriesCollection dataset1 = new XYSeriesCollection();

        dataset1.addSeries(testValue3.vfunciterations);
        JFreeChart chart = ChartFactory.createXYLineChart("Thats in Java!", "states", "value", dataset1,
                PlotOrientation.VERTICAL,true, true, false);
        try {
            ChartUtilities.saveChartAsJPEG(new File("/Users/dillonflannery-valadez/IdeaProjects/Line" +
                            "/chart.jpg"),
                    chart, 500, 500);
        } catch (Exception e) {
            System.out.println("bad!");
        }
        final long end = System.currentTimeMillis();
        double time =(end -start)/1000.0;
        System.out.printf("Running time for 10 ,20 and 40 iterations: %.4f secs," +
                " Grid spacing 1000. \n", time );
    }

}

