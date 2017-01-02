/**
 * Created by dillonflannery-valadez on 11/16/15.
 */
import java.awt.*;
import java.util.ArrayList;

public class DrawGraphics {
    BouncingBox box;
    ArrayList<BouncingBox> newList = new ArrayList<BouncingBox>(3);

    /** Initializes this class for drawing. */
    public DrawGraphics() {
        box = new BouncingBox(200, 200, Color.RED);
        BouncingBox x1 = new BouncingBox(100,100, Color.black);
        BouncingBox x2 = new BouncingBox(200,70, Color.blue);
        BouncingBox x3 = new BouncingBox(40,150, Color.pink);
        x1.setMovementVector(0,1);
        x2.setMovementVector(5, -1);
        x3.setMovementVector(-3, 3);
        newList.add(x1);
        newList.add(x2);
        newList.add(x3);


    }



    /** Draw the contents of the window on surface. Called 20 times per second. */
    public void draw(Graphics surface) {
        int[] xpoints = {280, 10, 40, 10, 280, 240,240};
        int[] ypoints = {280, 280, 200, 10, 10, 100,200};
        int npoints = xpoints.length;
        Polygon myPoly = new Polygon(xpoints, ypoints, npoints);
        surface.drawRoundRect(50, 50, 100, 100, 20, 20);
        surface.draw3DRect(20,20,20, 100,false);
        surface.drawPolygon(myPoly);
        for(int i=0; i <3; i++){
            newList.get(i).draw(surface);
        }
//        box.draw(surface);
    }
}
