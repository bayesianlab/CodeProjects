/**
 * Created by dillonflannery-valadez on 11/21/15.
 */
import javafx.scene.shape.Circle;

import java.awt.Color; import java.awt.Graphics;
import java.util.ArrayList;
import java.util.Random;

public class DrawGraphics {
    Bouncer movingSprite;
    ArrayList<Mover> singleArrayListOfMovers = new ArrayList<>();

    public DrawGraphics() {
        Oval oval = new Oval(2,3,100,30, Color.BLUE);
        Rectangle box = new Rectangle(40, 60, Color.RED);
        Bouncer b1 = new Bouncer(30,100, 10,1, oval);
        Bouncer b2 = new Bouncer(9, 9, -3, -2, box);
        // Straight Movers //
        Rectangle box2 = new Rectangle(80,20, Color.GREEN);
        Oval oval2 = new Oval(100, -200, 50, 20, Color.BLACK);
        StraightMover b3, b4;
        b3 = new StraightMover(50, 50, 4,1, oval2);
        b4 = new StraightMover(60, 60,3,-2,  box2);

        singleArrayListOfMovers.add(b1);
        singleArrayListOfMovers.add(b2);
        singleArrayListOfMovers.add(b3);
        singleArrayListOfMovers.add(b4);
    }

    public void draw(Graphics surface) {
//        System.out.println(container);
        for(int i=0; i < singleArrayListOfMovers.size(); i ++){
           singleArrayListOfMovers.get(i).draw(surface);
        }

    }
}