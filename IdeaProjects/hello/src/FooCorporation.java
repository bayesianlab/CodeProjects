public class FooCorporation {
    public static void main(String[] arguments){
        double employee1 = pay(7.50, 37);
        double employee2 = pay(8.2, 47);
        double employee3 = pay(10.0, 73);
        System.out.println(employee1);
        System.out.println(employee2);
        System.out.println(employee3);
    }
    public static double pay(double pay, int hours){
        double grossInc = 0 ;
        if (hours > 40){
            grossInc = ((hours - 40) * pay * 1.5) + (40 * pay);
            return grossInc;
        }
        grossInc = pay*hours;
        return grossInc;
    }
}