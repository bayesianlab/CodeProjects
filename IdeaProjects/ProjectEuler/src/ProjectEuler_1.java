import java.util.ArrayList;

/**
 * Created by dillonflannery-valadez on 12/14/15.
 */
public class ProjectEuler_1 {

    int maximum = 1000;
    ArrayList multiples = new ArrayList();

    public ArrayList multiplesOf3(){
        int iterator = 1;
        int newMultiple = 0;
         while( true) {
             if(iterator % 5 != 0){
                 newMultiple = 3 * iterator;
                 if( newMultiple < maximum){
                     multiples.add(newMultiple);
                 } else break;
             }
             iterator += 1;
        }
        return multiples;
    }

    public ArrayList multiplesOf5(){
        int iterator = 1;
        int newMultiple = 0;
        while( true) {
            newMultiple = 5 * iterator;
            iterator += 1;
            if( newMultiple < maximum){
                multiples.add(newMultiple);
            } else break;
        }
        return multiples;
    }

    public int sumArrayList(ArrayList listOfNums){
        int sum = 0;
        for(int i = 0 ; i < listOfNums.size(); i ++){
            int x = (int) listOfNums.get(i);
            sum += x;
        }
        return sum ;
    }
}
