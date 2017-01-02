/**
 * Created by dillonflannery-valadez on 11/11/15.
 */
class Marathon {
    public static void main (String[] arguments) {
        String[] names = {
                "Elena", "Thomas", "Hamilton", "Suzie", "Phil", "Matt", "Alex",
                "Emma", "John", "James", "Jane", "Emily", "Daniel", "Neda",
                "Aaron", "Kate"
        };

        int[] times = {
                341, 273, 278, 329, 445, 402, 388, 275, 243, 334, 412, 393, 299,
                343, 317, 265
        };

        for (int i = 0; i < names.length; i++) {
            System.out.println(names[i] + ": " + times[i]);
        }
        int fastest = 0;
        int second = 0;
        second = findSecondFastest(times);
        fastest = findFastest(times);
        System.out.println("Find fastest " + names[fastest] + " with time " + times[fastest]);
        System.out.println("Find Second Fastest " + names[second] + " with time " + times[second]);
    }
    public static int findFastest(int[] finishTimes){
        int currentMin = finishTimes[0];
        int index = 0;
        for(int i = 0; i < finishTimes.length; i++) {
            if(currentMin > finishTimes[i]){
                currentMin = finishTimes[i];
                index = i;
            }
        }
        return index;
    }
    public static int findSecondFastest(int[] finishTimes){
        int fastest = finishTimes[findFastest(finishTimes)];
        int sum = 0;
        for(int i = 0; i < finishTimes.length; i++){
            sum = sum + finishTimes[i];
        }
        int index = 0;
        int secondFastest = sum ;
        for(int i =0; i < finishTimes.length; i ++){
            if((secondFastest > finishTimes[i]) && (finishTimes[i] != fastest)){
                secondFastest = finishTimes[i];
                index = i;
            }
        }
        return index;
    }
}