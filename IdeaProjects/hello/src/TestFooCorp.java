/**
 * Created by dillonflannery-valadez on 11/11/15.
 */
public class TestFooCorp extends FooCorporation {
    public static final String ANSI_RED = "\u001B[31m";
    public static final String ANSI_GREEN = "\u001B[32m";
    public static void main(String[] arguments) {
        System.out.println(firstTest());
    }
    public static String firstTest(){
        return ANSI_RED + "Failed";
    }


}
