import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Created by dillonflannery-valadez on 12/19/15.
 */
public class ConstructPrimeList {

    ArrayList primeNumberList = new ArrayList();


    public ArrayList readLines(String filename) throws IOException {
        FileReader fileReader = new FileReader(filename);

        BufferedReader bufferedReader = new BufferedReader(fileReader);
        ArrayList lines = new ArrayList();
        String line = null;
        int x = 0;
        int y = 0;
        while( (line = bufferedReader.readLine()) != null){
            for(String retval: line.split(",")){
                if(y != 0){
                    lines.add(retval);
                } y+= 1;
            }
            y = 0;
        }
        lines.remove(0);
        return lines;
    }

    public ArrayList readMoreLines(String filename) throws IOException {
        FileReader fileReader = new FileReader(filename);

        BufferedReader bufferedReader = new BufferedReader(fileReader);
        ArrayList lines = new ArrayList();
        String line = null;
        while( (line = bufferedReader.readLine()) != null){
            lines.add(line);
        }
        return lines;
    }

    public void constructAnotherList(String path){
        if(primeNumberList.size() <= 0 ){
            primeNumberList.add(1);
        }

        ArrayList x = new ArrayList();
        try {
            x = readMoreLines(path);
        } catch (IOException e) {
            e.printStackTrace();
        }
        for(int i = 0; i < x.size(); i ++){
            String y = (String) x.get(i);
            primeNumberList.add(Integer.parseInt(y));
        }
    }
}
