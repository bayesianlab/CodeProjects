import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;

import java.io.IOException;

/**
 * Created by dillonflannery-valadez on 1/3/16.
 */
public class Magic_Squares_Tests {

    Magic_Squares testCase = new Magic_Squares();
    String path = "/Users/dillonflannery-valadez/IdeaProjects/Final MIT Assignment/Luna.txt";
    String path2 = "/Users/dillonflannery-valadez/IdeaProjects/Final MIT Assignment/Luna.txt";

    public void test_sumRows() throws IOException{
        System.out.println(testCase.sumRows(path));
        System.out.println(testCase.sumRows(path2));

    }

    public void test_sumColumns() throws IOException{
        System.out.println(testCase.sumColumns(path));
        System.out.println(testCase.sumColumns(path2));
    }

    public void test_sumDiagonal() throws  IOException{
        System.out.println(testCase.checkDiagonal(path));
    }

    public void test_reverseDiagonal() throws IOException{
        System.out.println(testCase.checkReverseDiagonal(path));
    }

    public void test_declare() throws IOException{
        System.out.println(testCase.declareMagicSquare(path));
        System.out.println(testCase.declareMagicSquare(path2));
    }

    public static void main(String[] args) throws IOException{
        Magic_Squares_Tests runTests = new Magic_Squares_Tests();
        runTests.test_sumRows();
        runTests.test_sumColumns();
        runTests.test_sumDiagonal();
        runTests.test_reverseDiagonal();

        runTests.test_declare();


    }
}
